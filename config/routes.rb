Rails.application.routes.draw do

  get '/admin', to: "pages#admin"

  get '/tools/previous_fab'
  get '/tools/next_fab'
  get '/tools/create_model_user'
  post '/tools/send_reminders', to: "tools#send_reminders"
  post '/tools/send_report_on_aftermath', to: "tools#send_report_on_aftermath"
  post '/tools/populate_users', to: "tools#populate_users"

  resources :teams
  get '/v', to: "visitors#version"
  root to: 'visitors#index'
  devise_for :users
  post '/u/overriden_create', to: 'users#overriden_create'

  resources :users do
    resources :fabs
  end

end
