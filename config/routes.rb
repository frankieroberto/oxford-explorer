Rails.application.routes.draw do

  resources :collections, only: [:index, :show]

  root to: 'home#show'

end
