require 'api_constraints'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'welcome/index'
  root 'welcome#index'

  # User auth token
  #get "users/:id/auth_token", to: 'users#auth_token', :as => 'auth_token'

  # Loans
  get 'loans/index'
  root 'loans#index'

  # All resources
  resources :users do
    member do
      get :auth_token
    end
  end

  resources :requests
  put 'requests/:id/clear' => 'requests#clear', :as => 'clear_request'    # Clears items from requests
  patch 'requests/:id/clear', to: 'requests#clear'
  #	get 'requests/:id/placeorder' => 'requests#place', :as => 'place_order'

  get  'items/import' => 'items#import_upload', :as => 'import_upload'
  post 'items/import' => 'items#bulk_import', :as => 'bulk_import'

  get  'settings/dates' => 'settings#dates', :as => 'date_selection'
  put'settings/dates' => 'settings#update_dates', :as => 'update_dates'
  patch 'settings/dates', to: 'settings#update_dates'


  resources :items do
    member do
      post :convert_to_stocks
      post :create_stocks
      post :convert_to_global
    end
    resources :stocks
  end

  resources :tags
  resources :request_item_stocks
  resources :item_custom_fields, :only => [:index, :show, :create, :update, :destroy]
  resources :custom_fields, :only => [:create, :destroy]
  resources :sessions
  resources :logs
  resources :request_items, :except => [:index] do
    member do
      put :return , as: :return
      put :disburse_loaned, as: :disburse_loaned
    end
  end
  get 'request_items/:id/specify_return_serial_tags' => 'request_items#specify_return_serial_tags', :as => 'return_assets'



  resources :subscribers
  resources :settings

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
      resources :users, :only => [:index, :show, :create, :destroy] do
        member do
          put :update_password
          patch :update_password

          put :update_status
          patch :update_status

          put :update_privilege
          patch :update_privilege
        end
      end

      resources :custom_fields, :only => [:index, :show, :create, :destroy] do
        member do
          put :update_name
          patch :update_name

          put :update_privacy
          patch :update_privacy

          put :update_type
          patch :update_type
        end
      end

      resources :items, :only => [:index, :show, :create, :destroy] do
        member do
          post :convert_to_stocks
          delete :convert_to_global

          post :create_tag_associations

          delete :destroy_tag_associations

          put :update_general
          patch :update_general

          put :fix_quantity
          patch :fix_quantity

          put :clear_field_entries
          patch :clear_field_entries

          put :update_field_entry
          patch :update_field_entry

          post :bulk_import

          get :self_outstanding_requests

          get :self_loans
        end
      end

      resources :stocks, :only => [:index, :show] do
        member do

        end
      end

      resources :requests, :only => [:index, :show, :create] do
        member do
          put :decision
          patch :decision

          post :create_req_items
          delete :destroy_req_items

          put :update_general
          patch :update_general

          put :update_req_items
          patch :update_req_items

          put :return_req_items
          patch :return_req_items

          get :index_subrequests
        end
      end

      resources :tags, :only => [:index, :show, :create, :update, :destroy]
      resources :logs, :only => [:index, :show, :create, :update, :destroy]
      resources :sessions, :only => [:create, :destroy]
      resources :subscribers, :only => [:index, :create, :destroy]
      resources :settings, :only => [:index] do
        member do
          put :modify_email_subject
          patch :modify_email_subject

          put :modify_email_body
          patch :modify_email_body

          put :modify_email_dates
          patch :modify_email_dates
        end
      end
    end
  end

  # Swagger API
  get '/api' => redirect('/swagger/dist/index.html?url=/apidocs/api-docs.json')

end
