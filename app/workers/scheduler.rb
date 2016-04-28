module Scheduler
  @queue = :master
  # The scheduler is responsible for queueing all workers.
  # Runs every 5min 
  # Queries the db for workers that are active and are due to be run

  def self.perform
    # Retreive active bots from db
    p 'Here'
    bots = Bot.where(platform: :twitter, status: 1)
    # Retrieve each bot client
    p 
    bots.each do |bot|
      p "Scheduler running for bot id: #{bot.id}"
      twitter_bot = bot.twitter_bot
      client = twitter_bot.twitter_client.set_client
      client.rate_limits
      # Schedule Follow, Unfollow, Like, Comment based on rate limit
      Resque.enqueue(TwitterWorker)
    end
  end
    

end