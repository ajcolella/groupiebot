require 'rails_helper'

describe Bot do

  before_create do |bot| 
    @bot = Bot.new(
      status: 1
      created_at: DateTime.now
      updated_at: DateTime.now
      platform: "twitter"
      time_left: 0
      # user_id: create(:user).id
    )
  end
  subject { @bot }

  it "should set the child bot and child client" do
    expect(@child_bot.id).to equal = TwitterBot.first.id
  end
end


# describe User do

#   before(:each) { @user = User.new(email: 'user@example.com') }

#   subject { @user }

#   it { should respond_to(:email) }

#   it "#email returns a string" do
#     expect(@user.email).to match 'user@example.com'
#   end

# end