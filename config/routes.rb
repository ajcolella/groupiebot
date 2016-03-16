Rails.application.routes.draw do
  resources :bots
  root to: 'visitors#index'
  get 'products/:id', to: 'products#show', :as => :products
  devise_for :users
  resources :users

  # resource :twitter_account
  post 'users/connect_to_twitter', to: 'users#connect_to_twitter', as: :connect_to_twitter
  get '/callback/twitter/', to: "users#callback", as: :twitter_callback
end
