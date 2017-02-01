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
  end
  subject { @bot }
end


# describe User do

#   before(:each) { @user = User.new(email: 'user@example.com') }

#   subject { @user }

#   it { should respond_to(:email) }

#   it "#email returns a string" do
#     expect(@user.email).to match 'user@example.com'
#   end

# end