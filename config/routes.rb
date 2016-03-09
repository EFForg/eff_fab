Rails.application.routes.draw do

  get '/admin', to: "pages#admin"

  post '/tools/send_reminders', to: "tools#send_reminders"

  post '/tools/populate_users', to: "tools#populate_users"

  resources :teams
  get '/v', to: "visitors#version"
  root to: 'visitors#index'
  devise_for :users

  resources :users do
    resources :fabs
  end

end
