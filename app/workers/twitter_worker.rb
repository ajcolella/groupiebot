module TwitterWorker
  @queue = :twitter_queue

    def self.perform(bot_id = '')
      begin
        p "Performing Twitter Worker on Bot #: #{bot}"
        twitter_bot = Bot.find(bot_id).twitter_bot
        p twitter_bot
        # client = twitter_bot.twitter_client.set_client
        # client.rate_limits
        # Check rate limits
        # Get settings
        # Update client stats
        # Unfollow
        # Get num to follow
        # Follow/Like/Retweet
        # Check rate limit time
        # Update last_run
      rescue
        # If failure, set bot to inactive and email support
        p "Update for Bot # #{bot_id} has failed."
        # TODO email support lol
      end
    end
end
