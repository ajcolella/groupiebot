class TwitterBot < ActiveRecord::Base
  belongs_to :bot
  has_one :twitter_client
  after_initialize :set_client
  # serialize :tags, Array

  def username
    @twitter_client.username
  end

  def follower_count
    @twitter_client.followers.length
  end

  def following_count
    @twitter_client.following.length
  end
  
  # **Bot Methods**
  # The amount of people that can be followed before hitting the max followers limit
  def number_to_follow
    # 20% more followers or 2000 as estimated follow limit
    maxFollowers = (self.follower_count / 20).floor + self.follower_count
    # Prevent negative #'s, Max at 12 follows at a time for rate limiting
    numToFollow = [[0, maxFollowers - self.following_count].max, 12].min
    p "**** To Follow for #{username} --> #{numToFollow}, 
          Followers: #{self.follower_count}, Following: #{self.following_count}"
    numToFollow
  end

  def follow
    # Follow back users that have followed you
    users_followed_back = follow_back(app, followers, numToFollow) if self.follow_method

    # # Reduce number of users to follow
    # numToFollow -= users_followed_back.length
    # # Retrieve tags for search
    # tag = app[:tags].sample
    # app[:client].search(tag, result_type: "recent").take(numToFollow).collect do |tweet| 
    #   p "**** Following for #{app[:name]} --> #{tweet.user.screen_name}: #{tweet.text} #{tweet.created_at}"
      
    #   screen_name = tweet.user.screen_name
    #   twitter_id = tweet.user.id
    # end
  end

  private
  def set_client
    @twitter_client = self.twitter_client
  end
end