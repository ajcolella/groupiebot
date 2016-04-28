module TwitterWorker
  @queue = :twitter_queue

    def self.perform(bot_id = '')
      p "Performing Twitter Worker on #{bot_id}"
      # Check rate limits
      # Get settings
      # Update client stats
      # Unfollow
      # Get num to follow
      # Follow/Like/Retweet
      # Check rate limit time
      # Update last_run
    end
end
