module TwitterWorker
  @queue = :twitter_queue

    def self.perform
    # Fetch all active twitter bots

    bots = Bot.where(platform: :twitter, status: 1)
    bots.each do |bot|
      p bot.id
      settings = bot.twitter_bot
      settings.twitter_client.set_client
    end
    # Check rate limits
    # Get settings
    # Update client stats
    # Unfollow
    # Get num to follow
    # Follow/Like/Retweet
    # Check rate limit time
  end

  def self.check_rate_limits(type = '')
    p 'check rate limits here'
  end
end
