require 'api_constraints'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'welcome/index'

  # TODO: Deprecated... All test associated with this are irrelevant
  # get '/signup', to: 'users#new'
  # post '/signup', to: 'users#create'

  resources :users
  resources :requests
    put 'requests/:id/clear' => 'requests#clear', :as => 'clear_request'    # Clears items from requests
    patch 'requests/:id/clear', to: 'requests#clear'
  resources :items
  resources :tags
  resources :request_items
  resources :item_custom_fields, :only => [:index, :show, :create, :update, :destroy]
  resources :custom_fields, :only => [:create, :destroy]

  #Login and Sessions routes
  get   '/login',   to: 'sessions#new'      #Describes the login screen
  post  '/login',   to: 'sessions#create'   #Handles actually logging in
  delete '/logout', to: 'sessions#destroy'  #Handles logging out


  get '/auth/:provider/callback', to: 'sessions#create'

  resources :sessions

  #Log Routes
  resources :logs

  root 'welcome#index'

  ## Maps to app/controllers/api directory
  namespace :api, defaults: { format: :json } do
    scope module: :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      # List of resources
      resources :users, :only => [:index, :show, :create, :update, :destroy]
      resources :requests, :only => [:index, :show, :create, :update, :destroy]
      resources :items, :only => [:index, :show, :create, :update, :destroy]
      resources :tags, :only => [:index, :show, :create, :update, :destroy]
      resources :logs, :only => [:index, :show, :create, :update, :destroy]
      resources :sessions, :only => [:create, :destroy]
    end
  end
end
