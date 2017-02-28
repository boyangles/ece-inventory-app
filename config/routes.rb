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
    put 'requests/:id/clear' => 'requests#clear', :as => 'clear_request'    # Clears items from requests
    patch 'requests/:id/clear', to: 'requests#clear'
	#	get 'requests/:id/placeorder' => 'requests#place', :as => 'place_order'
  resources :items do
		member do
			get :edit_quantity
			put :update_quantity
			patch :update_quantity	# in order to create separate form to specify quantity change - javascript?
		end
	end
  resources :tags
  
  resources :item_custom_fields, :only => [:index, :show, :create, :update, :destroy]
  resources :custom_fields, :only => [:create, :destroy]
  resources :sessions
  resources :logs
  resources :request_items, :except => [:index, :show]

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
        end
      end

      resources :requests, :only => [:index, :show, :create, :update, :destroy] do
        member do
          put :decision
          patch :decision

          post :create_req_items
          delete :destroy_req_items

          put :update_req_items
          patch :update_req_items
        end
      end
      resources :tags, :only => [:index, :show, :create, :update, :destroy]
      resources :logs, :only => [:index, :show, :create, :update, :destroy]
      resources :sessions, :only => [:create, :destroy]
    end
  end

  # Swagger API
  get '/api' => redirect('/swagger/dist/index.html?url=/apidocs/api-docs.json')

end
