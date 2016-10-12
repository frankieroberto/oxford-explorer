Rails.application.routes.draw do

  resources :collections, only: [:index, :show]

  resources :items, only: [:show]

  root to: 'home#show'

end
