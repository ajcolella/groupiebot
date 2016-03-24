class Bot < ActiveRecord::Base
  belongs_to :users
  has_one :twitter_bot
  enum status: [:inactive, :active, :pending]
  after_initialize :set_child_bot

  def username
    @child_bot.username
  end

  def follower_count
    @child_bot.follower_count
  end

  def following_count
    @child_bot.following_count
  end

  def update_bot_details
    @child_client.update_bot_details(@child_bot.id)
  end

  private

  def set_child_bot
    platform = self.platform.downcase
    @child_bot = eval("self.#{platform}_bot")
    @child_client = eval("@child_bot.#{platform}_client")
  end
end
