Rails.application.routes.draw do

  root to: 'pages#home'
  get '/admin', to: "pages#admin"
  get '/about', to: "pages#about"

  get '/tools/previous_fab'
  get '/tools/next_fab'
  get '/tools/create_model_user'
  post '/tools/send_reminders', to: "tools#send_reminders"
  post '/tools/send_report_on_aftermath', to: "tools#send_report_on_aftermath"
  post '/tools/populate_users', to: "tools#populate_users"
  post '/tools/populate_this_weeks_fabs', to: "tools#populate_this_weeks_fabs"
  get '/v', to: "tools#version"


  resources :teams
  devise_for :users
  post '/u/overridden_create', to: 'users#overridden_create'

  resources :users do
    resources :fabs
  end

  namespace :api do
    resources :users, only: [:create, :destroy]
  end
end
