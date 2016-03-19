class TwitterBotController < ApplicationController
  def new
    twitter_bot = TwitterBot.create
    redirect_to(twitter_bot.authorize_url(twitter_callback_url))
  end
  
  def callback
    if params[:denied] && !params[:denied].empty?
      redirect_to(bots_path, :alert => 'Unable to connect with twitter: #{parms[:denied]}')
    else
      twitter_bot = TwitterBot.find_by(twitter_oauth_token: params[:oauth_token])
      twitter_bot.validate_oauth_token(params[:oauth_verifier], twitter_callback_url)
      twitter_bot.save!
      if twitter_bot.connected?
        parent_bot = Bot.create(platform: :twitter, user_id: current_user.id)
        twitter_bot.update!(bot_id: parent_bot.id)
        redirect_to(bots_path, :notice => 'Twitter bot activated!')
      else
        twitter_bot.destroy
        redirect_to(bots_path, :notice => "Unable to activate twitter bot.")
      end
    end
  end
end