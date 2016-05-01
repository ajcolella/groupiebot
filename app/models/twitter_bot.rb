class TwitterBot < ActiveRecord::Base
  # Twitter Bots hold the specific settings of the bot and 
  # inform how the bot interacts with the twitter platform
  belongs_to :bot
  has_one :twitter_client
  after_initialize :set_client

  def username
    @twitter_client.username
  end

  def follower_count
    @twitter_client.followers.length
  end

  def following_count
    @twitter_client.following.length
  end

  private
  def set_client
    @twitter_client = self.twitter_client
  end
end