class TwitterUser < ActiveRecord::Base
  # Follow status is from Twitter Client perspective
  enum follow_status: [:inactive, :pending, :follower, :following, :friend]
end
