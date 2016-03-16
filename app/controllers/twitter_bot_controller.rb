class TwitterBotController < ApplicationController
  def new
    twitter_bot = TwitterBot.create(:user => current_user)
    redirect_to(view_context.authorize_twitter_url(current_user, twitter_callback_url))
  end
  
  def callback
    if params[:denied] && !params[:denied].empty?
      redirect_to(deals_url, :alert => 'Unable to connect with twitter: #{parms[:denied]}')
    else
      twitter_bot = TwitterBot.find_by_oauth_token(params[:oauth_token])
      twitter_bot.validate_oauth_token(params[:oauth_verifier], twitter_callback_url)
      twitter_bot.save
      if twitter_bot.active?
        redirect_to(deals_url, :notice => 'Twitter bot activated!')
      else
        redirect_to(deals_url, :notice => "Unable to activate twitter bot.")
      end
    end
  end
end