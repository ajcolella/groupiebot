class TwitterClient < ActiveRecord::Base
  # The twitter client is responsible for all actions using the twitter api
  # This includes connecting to the api and storing relevant twitter info
  belongs_to :twitter_bot
  before_filter :set_client, only: [:rate_limits]

  #  ****** Twitter API Methods ******

  def rate_limits
    begin
      @client.get('/1.1/application/rate_limit_status.json')
    rescue Exception => e
      self.errors.add(:oauth_token, "Unable to send to twitter: #{e.to_s}")
    end
  end

  def post(message)
    begin
      client.update(message)
      return true
    rescue Exception => e
      self.errors.add(:oauth_token, "Unable to send to twitter: #{e.to_s}")
      return false
    end
  end

  def unfollow
    # Find all users that were followed 4 days ago
    all_followed_users = User.where('followed_at < ?',  DateTime.now - 4)
    @apps.each do |app|
      begin
        # Users followed per app
        users = all_followed_users.where(follow_for_app: app[:name]).map(&:twitter_id)
        # All users that are not following back
        all_users_not_following = app[:client].friend_ids.collect.to_a - app[:client].follower_ids.collect.to_a
        # Only unfollow users that were followed via the app
        users_to_unfollow = users.find_all { |user| all_users_not_following.include?(user) }.take(15)
        # Unfollow. Don't attempt to unfollow more that the rate limit (15)
        app[:client].unfollow(users_to_unfollow)
        p "**** Unfollowing for #{app[:name]} --> #{users_to_unfollow}"
        if !(users_following_back = users - users_to_unfollow).nil?
          User.where(twitter_id: users_following_back, following_back: nil).update_all(following_back: true) 
        end
      rescue
        puts app[:name], 'Unfollow Error, Breaking'
      end
    end
  end

  #  ******* TwitterClient Object Methods ******

  def update_bot_details(twitter_bot_id)
    if twitter_bot_id.nil?
      destroy_client
    else
      set_client
      self.twitter_bot_id = twitter_bot_id
      user = @client.user
      self.twitter_id = user.id
      self.username = user.screen_name
      self.followers = @client.follower_ids.to_a
      self.following = @client.friend_ids.to_a
      self.save!
    end
  end

  def destroy_client
    self.destroy
    p self.id, 'Twitter Client Orphaned and Destroyed'
    redirect_to(bots_path, :notice => "Unable to establish connection with Twitter. Please reconnect.")
  end

  def connected_to_twitter
    !(self.twitter_id.nil? && 
      self.twitter_oauth_token.nil? && 
      self.twitter_oauth_token_secret.nil? &&
      self.twitter_oauth_token_verifier.nil? && 
      twitter_oauth_authorize_url.nil?
    )
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

  def set_client
    p @client, 'Fetching twitter client'
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_key
      config.consumer_secret = Rails.application.secrets.twitter_secret
      config.access_token = self.twitter_oauth_token
      config.access_token_secret = self.twitter_oauth_token_secret
    end
  end
end
