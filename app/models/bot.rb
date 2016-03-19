class Bot < ActiveRecord::Base
  belongs_to :users
  has_many :twitter_bots
  enum status: [:inactive, :active, :pending]
end
