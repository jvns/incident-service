Rails.application.routes.draw do
  resources :puzzles do
    get 'run', on: :member
  end
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }, skip: [:registrations]

  get 'homepage/index'
  root 'homepage#index'

  resources :virtual_machine, only: [:index]
end
