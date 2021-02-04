Rails.application.routes.draw do
  get '/puzzles/:id/finished', to: 'puzzles#finished'
  post '/puzzles/:id/success', to: 'puzzles#success'

  get '/instances', to: 'sessions#index'
  get '/sessions/:id/stream', to: 'sessions#stream'


  resources :puzzles
  resources :sessions

  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }, skip: [:registrations]

  get 'homepage/index'
  get '/admin', to: 'homepage#admin'
  root 'homepage#index'

  resources :virtual_machine, only: [:index]
end
