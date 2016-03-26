Rails.application.routes.draw do
  resources :bots
  resources :twitter_bots, except: :show

  root to: 'visitors#index'
  devise_for :users
  resources :users

  post 'bots/connect_to_twitter', to: 'twitter_client#new', as: :connect_to_twitter
  get '/callback/twitter/', to: "twitter_client#callback", as: :twitter_callback
end
