Rails.application.routes.draw do
  get '/puzzles/:puzzle_id/run', to: 'vm_instance#show'
  get '/running_instances', to: 'vm_instance#show_all_json'
  resources :puzzles do
    get 'run', on: :member
  end
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }, skip: [:registrations]

  get 'homepage/index'
  root 'homepage#index'

  resources :virtual_machine, only: [:index]
end
