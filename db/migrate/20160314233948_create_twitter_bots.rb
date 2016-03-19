class CreateTwitterBots < ActiveRecord::Migration
  def change
    create_table :twitter_bots do |t|
      t.integer :twitter_id
      t.text :twitter_stream_url
      t.string :twitter_oauth_token
      t.string :twitter_oauth_token_secret
      t.string :twitter_oauth_token_verifier
      t.text :twitter_oauth_authorize_url
      t.boolean :connected

      t.timestamps null: false
    end
  end
end
