class TwitterBot < ActiveRecord::Base
  belongs_to :bot
  has_one :twitter_client
  after_initialize :set_client

  def username
    @client.username
  end

  def follower_count
    @client.followers.length
  end

  def following_count
    @client.following.length
  end

  private
  def set_client
    @client = self.twitter_client
  end
end