require 'api_constraints'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'welcome/index'
  root 'welcome#index'


  # User auth token
  get "users/:id/auth_token", to: 'users#auth_token', :as => 'auth_token'

  # All resources
  resources :users
  resources :requests
  resources :items
  resources :tags
  resources :sessions
  resources :logs

  #Login and Sessions routes
  get   '/login',   to: 'sessions#new'      #Describes the login screen
  post  '/login',   to: 'sessions#create'   #Handles actually logging in
  delete '/logout', to: 'sessions#destroy'  #Handles logging out

  # Duke OAuth callback
  get '/auth/:provider/callback', to: 'sessions#create'

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

  # Swagger API
  get '/api' => redirect('/swagger/dist/index.html?url=/apidocs/api-docs.json')

end
