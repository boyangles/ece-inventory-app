Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'welcome/index'

  #post '/signup', to: 'users#create'

  resources :users
  resources :requests
  resources :items
  resources :tags
  resources :request_items

  #Login and Sessions routes
  get   '/login',   to: 'sessions#new'      #Describes the login screen
  post  '/login',   to: 'sessions#create'   #Handles actually logging in
  delete '/logout', to: 'sessions#destroy'  #Handles logging out


  get '/auth/:provider/callback', to: 'sessions#create'

  resources :sessions

  #Log Routes
  resources :logs

  root 'welcome#index'

end
