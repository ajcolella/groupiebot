Rails.application.routes.draw do
  resources :bots
  resources :twitter_bots#, except: :show TODO nest under bots route

  root to: 'visitors#index'
  devise_for :users
  resources :users

  get 'queue_resque', to: 'visitors#queue_resque'
  post 'bots/connect_to_twitter', to: 'twitter_client#new', as: :connect_to_twitter
  get '/callback/twitter/', to: "twitter_client#callback", as: :twitter_callback
end
