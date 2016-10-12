Rails.application.routes.draw do

  resources :collections, only: [:index, :show]

  resources :things, only: [:show]

  resources :institutions, only: [:show]

  root to: 'home#show'

end
