class AddLastRunToBots < ActiveRecord::Migration
  def change
    add_column :bots, :last_run, :datetime
  end
end
