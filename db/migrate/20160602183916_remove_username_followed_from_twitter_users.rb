class RemoveUsernameFollowedFromTwitterUsers < ActiveRecord::Migration
  def change
    remove_column :twitter_users, :username_followed, :string
  end
end
