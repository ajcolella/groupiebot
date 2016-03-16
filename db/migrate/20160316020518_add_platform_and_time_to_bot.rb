class AddPlatformAndTimeToBot < ActiveRecord::Migration
  def change
    add_column :bots, :platform, :string
    add_column :bots, :time_left, :integer
  end
end
