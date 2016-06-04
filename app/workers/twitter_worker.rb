module TwitterWorker
  @queue = :twitter_queue

  def self.perform(bot_id = '')
    p "Performing Twitter Worker on Bot #: #{bot_id}"
    twitter_bot = Bot.find(bot_id).twitter_bot
    # TODO refactor (after_init in model...)
    twitter_client = twitter_bot.twitter_client
    twitter_client.set_client
    # # Check rate limits
    rate_limits = twitter_client.rate_limits
    # Update client stats
    # TODO separate into different, less frequent worker
    twitter_client.update_client_details
    # Get num to follow
    number_to_follow = twitter_client.number_to_follow(10)
    
    # Unfollow: number_to_unfollow, days_since_follow
    # TODO make days_since_follow a setting on twitter_bot
    twitter_client.unfollow(10, 1)
    # Follow back users that have followed since
    # TODO make follow back a setting on the twitter_bot
    # users_followed_back = twitter_client.follow_back(number_to_follow) #if twitter_bot.follow_back
    # Reduce number of users to follow
    # number_to_follow -= users_followed_back
    
    # Retrieve tags for search
    if !(tags = twitter_bot.tags).nil? && twitter_bot.follow_method == 0 # TODO check for settings follow by tag or user
      tag = tags.sample
      # Follow/Like/Retweet
      twitter_client.follow_by_tag(number_to_follow, tag)
    else
      p 'TODO Follow by user'
    end
    # Check rate limit time
    # Update last_run
  # rescue
  #   # If failure, set bot to inactive and email support
  #   p "Update for Bot # #{bot_id} has failed."
  #   # TODO email support lol
  # end
  end
end
