module TwitterUpdateFollowersWorker
  @queue = :twitter_queue

  def self.perform(twitter_bot_id, cursor = -1)
    p "Performing Twitter Update Followers Worker on Twitter Bot# #{twitter_bot_id}"
    client = TwitterBot.find(twitter_bot_id).twitter_client
    client.set_client
    client.update_followers(cursor) if client.follower_lookups_remaining > 0
  end
end