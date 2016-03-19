Rails.application.routes.draw do
  resources :bots

  root to: 'visitors#index'
  get 'products/:id', to: 'products#show', :as => :products
  devise_for :users
  resources :users

  post 'bots/connect_to_twitter', to: 'twitter_bot#new', as: :connect_to_twitter
  get '/callback/twitter/', to: "twitter_bot#callback", as: :twitter_callback
end
