class CreateTwitterUsers < ActiveRecord::Migration
  def change
    create_table :twitter_users do |t|
      t.bigint :twitter_id
      t.string :username_followed
      t.string :tag_followed
      t.string :twitter_client
      t.integer :follow_status, default: 0
      t.datetime :followed_at
      
      t.string :username
      t.string :name
      t.string :url
      t.string :followers_count
      t.string :location
      t.string :created_at
      t.string :description
      t.string :lang
      t.string :time_zone
      t.string :verified
      t.string :profile_image_url
      t.string :website
      t.string :statuses_count
      t.string :profile_background_image_url
      t.string :profile_banner_url

      t.timestamps null: false
    end
    # TODO maybe add reference
    # add_reference :twitter_clients, :twitter_users, index: true, foreign_key: true
  end
end
