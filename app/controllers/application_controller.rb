class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  #Makes the sessions helper available in all our controllers
  include SessionsHelper

end
