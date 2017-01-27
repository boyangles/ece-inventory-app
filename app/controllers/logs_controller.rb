class LogsController < ApplicationController
  #TODO Add before_action (i.e. only admins can access logs)
  
  def index
    @requests = Request.all
  end
end
