class TwitterBot < ActiveRecord::Base
  belongs_to :bot

  def connected_to_twitter
    !(self.twitter_id.nil? && 
      self.twitter_oauth_token.nil? && 
      self.twitter_oauth_token_secret.nil? &&
      self.twitter_oauth_token_verifier.nil? && 
      twitter_oauth_authorize_url.nil?
    )
  end
end
