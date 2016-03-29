class TwitterClientController < ApplicationController
  def new
    client = TwitterClient.create
    redirect_to(client.authorize_url(twitter_callback_url))
  end
  
  def callback
    if params[:denied] && !params[:denied].empty?
      redirect_to(bots_path, :alert => 'Unable to connect with twitter: #{parms[:denied]}')
    else
      client = TwitterClient.find_by(twitter_oauth_token: params[:oauth_token])
      client.validate_oauth_token(params[:oauth_verifier], twitter_callback_url)
      client.save!
      if client.connected?
        # Establish the connection Bot --> Child Bot --> Client only after twitter validation
        parent_bot = Bot.create(platform: :twitter, user_id: current_user.id)
        child_bot = TwitterBot.create(bot_id: parent_bot.id, client_id: client.id)
        # Setup initial twitter account info
        client.update_bot_details(child_bot.id)
        redirect_to(edit_twitter_bot_path(parent_bot), :notice => 'Twitter bot activated!')
      else
        client.destroy
        redirect_to(bots_path, :notice => "Unable to activate twitter bot.")
      end
    end
  end
end