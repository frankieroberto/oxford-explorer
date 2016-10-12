Rails.application.routes.draw do

  resources :collections, only: [:index, :show] do
    resources :sub_collections, only: [:show], path: ''
  end

  resources :things, only: [:show]

  resources :about, only: [:index]

  resources :people, only: [:show]

  resources :subjects, only: [:show], controller: :superfields, superfield: 'gfs_subject'
  resources :item_types, only: [:show], controller: :superfields, superfield: 'gfs_item_type'
  resources :years, only: [:show], controller: :superfields, superfield: 'gfs_pubyear'

  resources :institutions, only: [:show]

  root to: 'home#show'

end
