Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'welcome/index'

  resources :users, except: :new
    get '/signup', to: 'users#new'
    post '/signup', to: 'users#create'
  
  resources :requests

  root 'welcome#index'
  
end
