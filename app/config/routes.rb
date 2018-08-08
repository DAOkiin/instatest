Rails.application.routes.draw do
  devise_for :users
  root 'pages#home'
  # Authorize user
  get '/auth_token' => 'pages#auth_token'
end
