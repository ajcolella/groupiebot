class ChangeFrequncyToTypeAddDays < ActiveRecord::Migration
  def change
    add_column :twitter_bots, :follow, :boolean, default: true
    add_column :twitter_bots, :unfollow, :boolean, default: true
    add_column :twitter_bots, :like, :boolean, default: false
    add_column :twitter_bots, :days_since_follow, :integer, default: 4
    add_column :twitter_bots, :tags_for_likes, :string, array: true, default: []
    change_column :twitter_bots, :follow_back, :boolean, default: true
  end
end
