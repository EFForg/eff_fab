Rails.application.routes.draw do

  get '/admin', to: "pages#admin"

  post '/tools/send_reminders', to: "tools#send_reminders"

  resources :teams
  get '/v', to: "visitors#version"
  root to: 'visitors#index'
  devise_for :users

  resources :users do
    resources :fabs
  end

end
