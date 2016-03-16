FactoryGirl.define do
  factory :twitter_bot do
    twitter_id 1
    twitter_stream_url "MyText"
    twitter_oauth_token "MyString"
    twitter_oauth_token_secret "MyString"
    twitter_oauth_token_verifier "MyString"
    twitter_oauth_authorize_url "MyText"
  end
end
