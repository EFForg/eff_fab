Rails.application.routes.draw do
  resources :fabs
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
