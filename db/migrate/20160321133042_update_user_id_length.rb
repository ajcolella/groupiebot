class UpdateUserIdLength < ActiveRecord::Migration
  def change
    change_column :twitter_clients, :twitter_id, :integer, limit: 8
  end
end
