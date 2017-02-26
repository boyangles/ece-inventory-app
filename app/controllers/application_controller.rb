require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :null_session
  
  #Makes the sessions helper available in all our controllers
  include Authenticable
  include Renderable

  include SessionsHelper
  include RequestsHelper
  include ItemsHelper

end
