class TwitterClient < ActiveRecord::Base
  # The twitter client is responsible for all actions using the twitter api
  # This includes connecting to the api and storing relevant twitter info
  belongs_to :twitter_bot

  #  ****** Twitter API Methods ******

  def rate_limits
    begin
      limits = @client.get('/1.1/application/rate_limit_status.json')
      @rate_limits_remaining = limits[:resources][:application][:"/application/rate_limit_status"][:remaining]
      limits
    rescue Exception => e
      self.errors.add(:oauth_token, "Unable to send to twitter: #{e.to_s}")
    end
  end

  def following_lookups_remaining
    self.rate_limits[:resources][:friends][:"/friends/ids"][:remaining]
  end

  def follower_lookups_remaining
    self.rate_limits[:resources][:friends][:"/friends/ids"][:remaining]
  end

  def user_lookups_remaining
    self.rate_limits[:resources][:users][:"/users/lookup"][:remaining]
  end

  def tweet_searches_remaining
    self.rate_limits[:resources][:search][:"/search/tweets"][:remaining]
  end

  # The amount of people that can be followed before hitting the max followers limit
  def number_to_follow(user_limit)
    # 20% more followers or 2000 as estimated follow limit
    max_followers = [(follower_count / 20).floor + follower_count, 5000].max
    # Prevent negative #'s, Max at 12 follows at a time for rate limiting
    max_following_limit = [0, max_followers - following_count].max
    # Twitter limits 1000 follows per day: 10 follows per 15 minutes = 960
    max_day_limit = [user_limit, 10].min
    # Find the least to follow to not exceed max limit and day limit
    num_to_follow = [max_following_limit, max_day_limit].min
    # TODO check rate limit for adding friends and do 'min'
    p "**** To Follow for #{self.username} --> #{num_to_follow}"
    p "Followers: #{self.follower_count}, Following: #{self.following_count}"
    num_to_follow
  end

  def unfollow(num_to_unfollow, days_since_follow)
    # Find all users that were followed days_since_follow days ago
    user_ids_to_unfollow = self.pending_followers.
      where('followed_at < ?',  DateTime.now - days_since_follow
    ).map(&:twitter_id).take(num_to_unfollow)
    begin
      # Users followed per client
      res = @client.unfollow(user_ids_to_unfollow)
      unless res.length == 0
        TwitterUser.where(
          twitter_id: user_ids_to_unfollow, 
          twitter_client: self.id,
          follow_status: 1
        ).update!(follow_status: 0)
        p "**** Unfollowing for #{self.username} --> #{user_ids_to_unfollow}"
      end
      p "response", res
      res
    rescue
      puts "Unfollow Error for #{self.username}"
    end
  end

  def follow_by_tag(num_to_follow, tag, tweets = [])
    # Find tweets with specific words. Reverse to follow oldest tweet first.
    return if self.tweet_searches_remaining < 10 # Break if recursion hits rate limit
    tweets = @client.search(tag, result_type: "recent", count: 100) if tweets.length == 0
    num_to_retry = 0
    tweets.take(num_to_follow).each do |tweet|
      remote_user = tweet.user
      screen_name = remote_user.screen_name
      twitter_id = remote_user.id
      local_user = TwitterUser.where(
        twitter_id: twitter_id, twitter_client: self.id).first_or_initialize
      if local_user.new_record? && screen_name != self.username
        local_user.tag_followed = tag
        local_user.followed_at = DateTime.now
        res = @client.follow(screen_name)
        # Only save and update if follow was successful TODO check for errors
        unless res.length == 0
          local_user.save! 
          update_twitter_user(local_user, remote_user, 1) # TODO only one db call
          p "**** Following for #{self.username} --> #{screen_name}: #{tweet.text} #{tweet.created_at}"
        end
      else
        num_to_retry += 1
      end
    end
    # If user has already been followed, attempt to follow another user by retrieving more tweets
    p num_to_retry, tweets[num_to_retry..tweets.length], '**********'
    if num_to_retry > 0 && !(tweets_to_retry = tweets[num_to_retry..tweets.length]).nil?
      p "Follow more people for #{self.username}: #{num_to_retry}"
      follow_by_tag(num_to_retry, tag, tweets_to_retry)
    end
    p "Done following"
  end

  def follow_back(num_to_follow)
    # Find all users that followed, but are not friends
    user_ids_to_follow = self.followers.map(&:twitter_id).take(num_to_follow)
    if !user_ids_to_follow.nil?
      begin
        # Users followed per client and set follow status to friend
        res = @client.follow(user_ids_to_follow)
        unless res.length == 0
          TwitterUser.where(
            twitter_id: user_ids_to_follow, 
            twitter_client: self.id
          ).update!(follow_status: 4)
        end
        p "**** Following back for #{self.username} --> #{user_ids_to_follow}"
        res
      rescue
        puts "Follow Back Error for #{self.username}, #{res}"
      end
    else
      p "**** Following back for #{self.username} --> No users to follow back"
    end
    # Return number of twitter users followed
    res.nil? ? 0 : num_to_follow
  end

  #  ******* TwitterClient Object Methods ******
  
  # Store client details after the bot is created
  # TODO ensure only one bot per user
  def initialize_client_details(twitter_bot_id)
    begin
      if TwitterBot.find(twitter_bot_id).nil?
        destroy_client
      else
        set_client
        user = @client.user
        self.twitter_bot_id = twitter_bot_id
        self.twitter_id = user.id
        self.username = user.screen_name
        self.save!
        update_followers
        update_following
      end
    rescue
      puts self.id, "Unable to initialize connection with Twitter."
    end
  end

  # Update anything that may have changed since the last run of the TwitterWorker
  def update_client_details
    begin
      user = @client.user
      self.username = user.screen_name
      self.save!
      update_followers
      update_following
    rescue
      puts twitter_client.id, "Unable to update Twitter account details."
    end
  end

  def update_followers
    # TODO Move to a worker, make more efficient, and remove n+1 probs ie two methods, update full and update recent
    # Twitter users that the client is following
    if self.following_lookups_remaining
      remote_follower_ids = []
      @client.friend_ids(self.username).each_slice(100).with_index do |slice, i|
        @client.users(slice).each do |remote_user|
          local_user = TwitterUser.where(
            twitter_id: remote_user.id, 
            twitter_client: self.id,
            follow_status: 3
        ).first_or_create
          remote_follower_ids << remote_user.id
          update_twitter_user(local_user, remote_user, 3)
        end
      end
      # follow_status of Following (3) are whitelisted users
      # whitelist_ids = self.following.map(&:twitter_id) - self.pending_followers.map(&:twitter_id)
      # users_no_longer_following = whitelist_ids - remote_follower_ids
      # p "Users no longer Following #{self.username}: #{users_no_longer_following}"
      # TwitterUser.where(twitter_id: users_no_longer_following, 
      #   twitter_client: self.id).update!(follow_status: 0)
    end
  end

  def update_following
    # Twitter users that are following the client
    @client.follower_ids(self.username).each_slice(100).with_index do |slice, i|
      # TODO check rate limits
      @client.users(slice).each do |remote_user|
        local_user = TwitterUser.where(
          twitter_id: remote_user.id, 
          twitter_client: self.id
      ).first_or_initialize
        if local_user.new_record? || local_user.follow_status == "inactive"
          # If its a new follower status = follower
          p "New User #{remote_user.screen_name}"
          update_twitter_user(local_user, remote_user, 2)
        else local_user.follow_status == "pending" || local_user.follow_status == "following"
          # p "#{remote_user.screen_name} Followed Back"
          # If the follower followed back status = friend
          update_twitter_user(local_user, remote_user, 4)
        end
      end
    end
  end

  def update_twitter_user(local_user, remote_user, status)
    local_user.update!(
      username: remote_user.screen_name,
      name: remote_user.name,
      url: remote_user.url,
      followers_count: remote_user.followers_count,
      location: remote_user.location.gsub(/\n+/,' '),
      created_at: remote_user.created_at,
      description: remote_user.description.gsub(/\n+/,' '),
      lang: remote_user.lang,
      time_zone: remote_user.time_zone,
      # verified: remote_user.verified,
      profile_image_url: remote_user.profile_image_url,
      website: remote_user.website,
      statuses_count: remote_user.statuses_count,
      profile_background_image_url: remote_user.profile_background_image_url,
      profile_banner_url: remote_user.profile_banner_url,
      follow_status: status
    )
  end

  def destroy_client
    self.destroy
    p self.id, 'Twitter Client Orphaned and Destroyed'
    puts twitter_client.id, :notice => "Unable to establish connection with Twitter. Please reconnect."
  end

  def pending_followers
    TwitterUser.where(twitter_client: self.id, follow_status: 1)
  end

  def followers
    TwitterUser.where(twitter_client: self.id, follow_status: [2, 4])
  end

  def following
    TwitterUser.where(twitter_client: self.id, follow_status: [1, 3, 4])
  end

  def friends
    TwitterUser.where(twitter_client: self.id, follow_status: 4)
  end

  # TODO whitelist

  def follower_count
    self.followers.length
  end

  def following_count
    self.following.length
  end
  
  def friends_count
    self.friends.length
  end

  # ****** Twitter Auth Methods ******
  def authorize_url(callback_url = '')
    if self.twitter_oauth_authorize_url.blank?
      # Step one, generate a request URL with a request token and secret
      consumer = OAuth::Consumer.new(
        Rails.application.secrets.twitter_key, 
        Rails.application.secrets.twitter_secret, 
        {:site => "https://api.twitter.com", :request_endpoint => "https://api.twitter.com/1.1"}
      )
      request_token = consumer.get_request_token(:oauth_callback => callback_url)
      self.twitter_oauth_token = request_token.token
      self.twitter_oauth_token_secret = request_token.secret
      self.twitter_oauth_authorize_url = request_token.authorize_url
      self.save!
    end
    self.twitter_oauth_authorize_url
  end
  
  def validate_oauth_token(oauth_verifier, callback_url = '')
    begin
      consumer = OAuth::Consumer.new(
        Rails.application.secrets.twitter_key, 
        Rails.application.secrets.twitter_secret, 
        {:site => "https://api.twitter.com", :request_endpoint => "https://api.twitter.com/1.1"}
      )
      access_token = OAuth::RequestToken.new(
        consumer, 
        self.twitter_oauth_token, 
        self.twitter_oauth_token_secret
        ).get_access_token(:oauth_verifier => oauth_verifier
      )
      self.twitter_oauth_token = access_token.params[:oauth_token]
      self.twitter_oauth_token_secret = access_token.params[:oauth_token_secret]
      self.twitter_oauth_token_verifier = oauth_verifier
      self.connected = true
    rescue OAuth::Unauthorized
      self.errors.add(:twitter_oauth_token, "Invalid OAuth token, unable to connect to twitter")
      self.connected = false
    end
    self.save!
  end

  # Cache client in order to reduce number of calls to Twitter API
  def set_client
    p @client, 'Fetching twitter client'
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_key
      config.consumer_secret = Rails.application.secrets.twitter_secret
      config.access_token = self.twitter_oauth_token
      config.access_token_secret = self.twitter_oauth_token_secret
    end
  end

  def twitter_bot
    TwitterBot.find(self.twitter_bot_id)
  end
end
