require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :exception
  
  #Makes the sessions helper available in all our controllers
  include Authenticable

  include SessionsHelper
  include RequestsHelper
  include ItemsHelper

end
