class Bot < ActiveRecord::Base
  belongs_to :users
  has_one :twitter_bot
  enum status: [:inactive, :active, :pending]
  after_initialize :set_child_bot, except: :create

  def username
    @child_bot.username
  end

  def follower_count
    @child_bot.follower_count
  end

  def following_count
    @child_bot.following_count
  end

  def friends_count
    @child_bot.friends_count
  end

  def update_child_bot_details
    if !@child_client.nil?
      @child_client.update_bot_details(@child_bot.id)
    end
  end

  private

  def set_child_bot
    unless self.id.nil?
      platform = self.platform.downcase
      @child_bot = eval("self.#{platform}_bot")
      @child_client = eval("@child_bot.#{platform}_client")
    end
  end
end
