Rails.application.routes.draw do

  resources :collections, only: [:index, :show] do
    collection do
      get :json
    end
    resources :sub_collections, only: [:show], path: ''
  end

  resources :things, only: [:show]

  resources :about, only: [:index]

  resources :people, only: [:show], :constraints => {:id => /.*/}

  resources :subjects, only: [:show], controller: :superfields, superfield: 'gfs_subject', :constraints => {:id => /.*/}
  resources :item_types, only: [:show], controller: :superfields, superfield: 'gfs_item_type', :constraints => {:id => /.*/}
  resources :years, only: [:show], controller: :superfields, superfield: 'gfs_pubyear', :constraints => {:id => /.*/}

  resources :institutions, only: [:show]

  root to: 'home#show'

end
