class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.integer :status, default: 0
      t.timestamps null: false
    end
    add_reference :twitter_bots, :bot, index: true
  end
end
