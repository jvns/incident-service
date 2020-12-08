Rails.application.routes.draw do
  devise_for :users
  get 'homepage/index'
  root 'homepage#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }

  resources :virtual_machine, only: [:index]
end
