class AddDefaultsToTwitterBot < ActiveRecord::Migration
  def change
    change_column :twitter_bots, :follow_back, :boolean, default: false
    change_column :twitter_bots, :follow_method, :integer, default: 0
    change_column :twitter_bots, :frequency, :integer, default: 0
    # remove_column :twitter_bots, :twitter_client_id
  end
end
