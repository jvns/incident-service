Rails.application.routes.draw do
  get 'homepage/index'
  root 'homepage#index'

  resources :virtual_machine, only: [:index]
end
