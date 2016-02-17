Rails.application.routes.draw do

  get '/v', to: "visitors#version"
  root to: 'visitors#index'
  devise_for :users

  resources :users do
    resources :fabs
  end

end
