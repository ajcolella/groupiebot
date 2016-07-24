module TwitterUpdateFollowingWorker
  @queue = :twitter_queue

  def self.perform(twitter_bot_id, cursor = -1, remote_following_ids = [])
    p "Performing Twitter Update Following Worker on Twitter Bot# #{twitter_bot_id}"
    client = TwitterBot.find(twitter_bot_id).twitter_client
    client.set_client
    client.update_following(cursor, remote_following_ids) if client.following_lookups_remaining > 0
  end
end