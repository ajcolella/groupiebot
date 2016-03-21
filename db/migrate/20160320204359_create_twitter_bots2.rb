class CreateTwitterBots2 < ActiveRecord::Migration
  def change
    rename_column :twitter_clients, :bot_id, :twitter_bot_id
    create_table :twitter_bots do |t|
      t.text :tags, array: true, default: []
      t.boolean :follow_back
      t.integer :follow_method
      t.integer :frequency
      t.integer :bot_id
      t.integer :twitter_client_id
      t.timestamps null: false
    end
  end
end
