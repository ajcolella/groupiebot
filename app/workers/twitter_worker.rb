module TwitterWorker
  @queue = :twitter_queue

  def self.perform(bot_id = '')
    p "Performing Twitter Worker on Bot# #{bot_id}"
    bot = Bot.find(bot_id).twitter_bot
    client = bot.twitter_client
    client.set_client
    # Check rate limits
    p "checking rate limits"
    rate_limits = client.rate_limits
    # Update client stats
    client.update_client_details
    # Get num to follow
    number_to_follow = client.number_to_follow(10)

    p 'unfollowing'
    # Unfollow: number_to_unfollow, days_since_follow
    client.unfollow(14, 1)#bot.days_since_follow)
    # Follow back users that have followed since
    if bot.follow_back
      p 'following back'
      users_followed_back = client.follow_back(number_to_follow)
      # Reduce number of users to follow
      number_to_follow -= users_followed_back
    end
    
    # Retrieve tags for search
    # TODO Follow by user
    # if bot.follow
    p 'following by tag'
    if !(tags = bot.tags).nil? && bot.follow_method == 0 
      tag = tags.sample
      # Follow/Like/Retweet
      client.follow_by_tag(number_to_follow, tag)
    else
      p 'TODO Follow by user'
    end
    # end
    # Check rate limit time
    # Update last_run
  # rescue
  #   # If failure, set bot to inactive and email support
  #   p "Update for Bot # #{bot_id} has failed."
  #   # TODO email support lol
  # end
  end
end
