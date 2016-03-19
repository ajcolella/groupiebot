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

  def authorize_url(callback_url = '')
    if self.twitter_oauth_authorize_url.blank?
      # Step one, generate a request URL with a request token and secret
      consumer = OAuth::Consumer.new(
        Rails.application.secrets.twitter_key, 
        Rails.application.secrets.twitter_secret, 
        {:site => "https://api.twitter.com", :request_endpoint => "https://api.twitter.com/1.1"}
      )
      request_token = consumer.get_request_token(:oauth_callback => callback_url)
      self.twitter_oauth_token = request_token.token
      self.twitter_oauth_token_secret = request_token.secret
      self.twitter_oauth_authorize_url = request_token.authorize_url
      self.save!
    end
    self.twitter_oauth_authorize_url
  end
  
  def validate_oauth_token(oauth_verifier, callback_url = '')
    begin
      consumer = OAuth::Consumer.new(
        Rails.application.secrets.twitter_key, 
        Rails.application.secrets.twitter_secret, 
        {:site => "https://api.twitter.com", :request_endpoint => "https://api.twitter.com/1.1"}
      )
      access_token = OAuth::RequestToken.new(
        consumer, 
        self.twitter_oauth_token, 
        self.twitter_oauth_token_secret
        ).get_access_token(:oauth_verifier => oauth_verifier
      )
      self.twitter_oauth_token = access_token.params[:oauth_token]
      self.twitter_oauth_token_secret = access_token.params[:oauth_token_secret]
      self.twitter_stream_url = "http://twitter.com/#{access_token.params[:screen_name]}"
      self.connected = true
    rescue OAuth::Unauthorized
      self.errors.add(:twitter_oauth_token, "Invalid OAuth token, unable to connect to twitter")
      self.connected = false
    end
    self.save!
  end
end
