require 'api_constraints'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'welcome/index'

  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  resources :users, except: :new do
    member do
      get :confirm_email
    end
    member do
      post :approve_user
    end
  end

  resources :requests
  resources :items
  resources :tags


  #Login and Sessions routes
  get   '/login',   to: 'sessions#new'      #Describes the login screen
  post  '/login',   to: 'sessions#create'   #Handles actually logging in
  delete '/logout', to: 'sessions#destroy'  #Handles logging out

  #Log Routes
  resources :logs

  # User request page for admin
  resources :accountrequests

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
    end
  end
end
