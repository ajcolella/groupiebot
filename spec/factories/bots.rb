FactoryGirl.define do
  factory :bot do
    status 0

    factory twitter_bot do
      create(:twitter_bot)

      factory twitter_client do
        create(:twitter_client)
      end
    end
  end
end