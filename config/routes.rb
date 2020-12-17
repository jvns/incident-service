Rails.application.routes.draw do
  get '/puzzles/:puzzle_id/start', to: 'vm_instance#create'
  get '/puzzles/:puzzle_id/play', to: 'vm_instance#show'
  get '/puzzles/:id/finished', to: 'puzzles#finished'

  get '/instances/:digitalocean_id/shutdown', to: 'vm_instance#destroy'
  get '/instances/:digitalocean_id/status', to: 'vm_instance#status'
  get '/instances', to: 'vm_instance#index'
  resources :puzzles

  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }, skip: [:registrations]

  get 'homepage/index'
  get '/admin', to: 'homepage#admin'
  root 'homepage#index'

  resources :virtual_machine, only: [:index]
end
