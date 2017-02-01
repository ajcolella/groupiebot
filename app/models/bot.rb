class Bot < ActiveRecord::Base
  belongs_to :users
  has_one :twitter_bot
  enum status: [:inactive, :active, :pending]
end
