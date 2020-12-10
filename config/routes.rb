Rails.application.routes.draw do
  get '/puzzles/:puzzle_id/start', to: 'vm_instance#create'
  get '/puzzles/:puzzle_id/play', to: 'vm_instance#show'

  get '/instances/:instance_id/destroy', to: 'vm_instance#destroy'
  get '/running_instances', to: 'vm_instance#show_all_json'
  resources :puzzles
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }, skip: [:registrations]

  get 'homepage/index'
  root 'homepage#index'

  resources :virtual_machine, only: [:index]
end
