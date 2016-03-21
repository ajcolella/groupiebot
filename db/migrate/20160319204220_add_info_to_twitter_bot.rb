class AddInfoToTwitterBot < ActiveRecord::Migration
  def change
    add_column :twitter_bots, :username, :string
    add_column :twitter_bots, :followers, :text, array:true, default: []
    add_column :twitter_bots, :following, :text, array:true, default: []
    remove_column :twitter_bots, :twitter_stream_url, :string
  end
end
