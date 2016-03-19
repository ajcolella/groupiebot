class AddUserToBots < ActiveRecord::Migration
  def change
    add_reference :bots, :user, index: true, foreign_key: true
  end
end
