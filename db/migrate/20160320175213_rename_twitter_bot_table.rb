class RenameTwitterBotTable < ActiveRecord::Migration
  def change
    rename_table :twitter_bots, :twitter_clients
  end
end
