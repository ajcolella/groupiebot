module Scheduler
  @queue = :master
  # The scheduler is responsible for queueing all workers.
  # Runs every 5min 
  # Queries the db for workers that are active and are due to be run

  def self.perform
    # Enqueue Twitter Active Bots
    bots = Bot.where(status: 1)
    bots.each do |bot|
      worker = bot.platform.capitalize + "Worker"
      p "Queued #{worker} Bot# #{bot.twitter_bot.twitter_client.username}"
      Resque.enqueue(eval("#{worker}"), bot.id)

      # Enqueue Twitter Update Followers Workers
      if !(twitter_bot_followers_update = TwitterBot.where(
        'followers_updated_at < ?', DateTime.now - 1).where(is_updating_followers: false, bot_id: bot.id).first).nil?
        p "Queued Update Followers Worker for #{twitter_bot_followers_update.twitter_client.username}"
        twitter_bot_followers_update.update!(is_updating_followers: true)
        Resque.enqueue(TwitterUpdateFollowersWorker, twitter_bot_followers_update.id)
      end

      # Enqueue Twitter Update Following Workers
      if !(twitter_bot_following_update = TwitterBot.where(
          'following_updated_at < ?', DateTime.now - 1).where(is_updating_following: false, bot_id: bot.id).first).nil?
        p "Queued Update Following Worker for #{twitter_bot_following_update.twitter_client.username}"
        twitter_bot_following_update.update!(is_updating_following: true)
        Resque.enqueue(TwitterUpdateFollowingWorker, twitter_bot_following_update.id)
      end
    end
  end
end