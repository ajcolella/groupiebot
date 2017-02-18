require 'rails_helper'

describe Bot do

  before do |bot| 
    @bot = Bot.create(
      status: 1,
      created_at: DateTime.now,
      updated_at: DateTime.now,
      platform: "twitter",
      time_left: 0
    )
    @twitter_bot = TwitterBot.create(
      bot_id: @bot.id
    )
    @twitter_client = TwitterClient.create(
      username: "TestUser",
      twitter_bot_id: @twitter_bot.id
    )

  end
  subject { @twitter_client }
  it { should respond_to(:email) }

  rate_limits
  rate_limits_remaining
  following_lookups_remaining
  follower_lookups_remaining
  user_lookups_remaining
  tweet_searches_remaining
end


# describe User do

#   before(:each) { @user = User.new(email: 'user@example.com') }

#   subject { @user }

#   it { should respond_to(:email) }

#   it "#email returns a string" do
#     expect(@user.email).to match 'user@example.com'
#   end

# end