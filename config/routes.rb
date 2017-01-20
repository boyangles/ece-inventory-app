Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'static_pages/home'
  get 'static_pages/help'

  root 'static_pages#home'
end
