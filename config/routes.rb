Rails.application.routes.draw do

  resources :collections, only: [:index, :show] do
    collection do
      get :json
    end
    resources :sub_collections, only: [:show], path: ''
  end

  resources :institutions, only: [:show, :index]

  resources :things, only: [:show], :constraints => {:id => /.*/}

  resources :about, only: [:index]

  resources :people, only: [:show], :constraints => {:id => /.*/}

  resource :people, only: [:show], controller: :superfields, action: 'index', superfield: 'gfs_author'
  #resource :institutions, only: [:show], controller: :superfields, action: 'index', superfield: 'gfs_institution_id'

  resources :subjects, only: [:show, :index], controller: :superfields, superfield: 'gfs_subject', :constraints => {:id => /.*/}
  resources :item_types, only: [:show, :index], controller: :superfields, superfield: 'gfs_item_type', :constraints => {:id => /.*/}
  resources :years, only: [:show, :index], controller: :superfields, superfield: 'gfs_pubyear', :constraints => {:id => /.*/}


  root to: 'home#show'

end
