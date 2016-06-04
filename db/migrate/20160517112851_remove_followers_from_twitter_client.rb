class RemoveFollowersFromTwitterClient < ActiveRecord::Migration
  def change
    remove_column :twitter_clients, :followers, :text, array:true, default: []
    remove_column :twitter_clients, :following, :text, array:true, default: []
  end
end
