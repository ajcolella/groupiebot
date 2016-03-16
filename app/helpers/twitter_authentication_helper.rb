module TwitterAuthenticationHelper
  def authorize_url(user, callback_url = '')
    byebug
    if user.twitter_oauth_authorize_url.blank?
      # Step one, generate a request URL with a request token and secret
      consumer = OAuth::Consumer.new(
        Rails.application.secrets.twitter_key, 
        Rails.application.secrets.twitter_secret, 
        {:site => "https://api.twitter.com", :request_endpoint => "https://api.twitter.com/1.1"}
      )
      request_token = consumer.get_request_token(:oauth_callback => callback_url)
      user.twitter_oauth_token = request_token.token
      user.twitter_oauth_token_secret = request_token.secret
      user.twitter_oauth_authorize_url = request_token.authorize_url
      user.save!
    end
    user.twitter_oauth_authorize_url
  end
  
  def validate_twitter_oauth_token(user, oauth_verifier, callback_url = '')
    begin
      consumer = OAuth::Consumer.new(
        Rails.application.secrets.twitter_key, 
        Rails.application.secrets.twitter_secret, 
        {:site => "http://api.twitter.com", :request_endpoint => "http://api.twitter.com"}
      )
      access_token = OAuth::RequestToken.new(
        consumer, 
        user.twitter_oauth_token, 
        user.twitter_oauth_token_secret
        ).get_access_token(:oauth_verifier => oauth_verifier
      )
      user.twitter_oauth_token = access_token.params[:oauth_token]
      user.twitter_oauth_token_secret = access_token.params[:oauth_token_secret]
      user.stream_url = "http://twitter.com/#{access_token.params[:screen_name]}"
      user.active = true
    rescue OAuth::Unauthorized
      user.errors.add(:twitter_oauth_token, "Invalid OAuth token, unable to connect to twitter")
      user.active = false
    end
    user.save!
  end
  
  # def post(message)
  #   Twitter.configure do |config|
  #     config.twitter_key = Rails.application.secrets.twitter_key
  #     config.twitter_secret = Rails.application.secrets.twitter_secret
  #     config.twitter_oauth_token = self.twitter_oauth_token
  #     config.twitter_oauth_token_secret = self.twitter_oauth_token_secret
  #   end
  #   client = Twitter::Client.new
  #   begin
  #     client.update(message)
  #     return true
  #   rescue Exception => e
  #     self.errors.add(:twitter_oauth_token, "Unable to send to twitter: #{e.to_s}")
  #     return false
  #   end
  # end
end