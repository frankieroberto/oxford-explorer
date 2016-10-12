Rails.application.routes.draw do

  resources :collections, only: [:index, :show] do
    resources :sub_collections, only: [:show], path: ''
  end

  resources :things, only: [:show]

  resources :institutions, only: [:show]

  root to: 'home#show'

end
