Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  get 'homepage/index'
  root 'homepage#index'

  resources :virtual_machine, only: [:index]
end
