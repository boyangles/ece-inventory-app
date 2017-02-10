Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'welcome/index'

  post '/signup', to: 'users#create'

  resources :users, except: :new do
    member do
      get :confirm_authentication
    end
  end

  resources :requests
  resources :items
  resources :tags


  #Login and Sessions routes
  get   '/login',   to: 'sessions#new'      #Describes the login screen
  # post  '/login',   to: 'sessions#create'   #Handles actually logging in
  delete '/logout', to: 'sessions#destroy'  #Handles logging out


  get '/auth/:provider/callback', to: 'welcome#index'

  resources :sessions

  #Log Routes
  resources :logs

  root 'welcome#index'

end
