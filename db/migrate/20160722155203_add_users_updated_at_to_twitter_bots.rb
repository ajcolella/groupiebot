class AddUsersUpdatedAtToTwitterBots < ActiveRecord::Migration
  def change
    add_column :twitter_bots, :following_updated_at, :datetime, default: DateTime.now
    add_column :twitter_bots, :is_updating_following, :boolean, default: false
    add_column :twitter_bots, :followers_updated_at, :datetime, default: DateTime.now
    add_column :twitter_bots, :is_updating_followers, :boolean, default: false
  end
end
