class LogsController < ApplicationController
  #TODO Add before_action (i.e. only admins can access logs)
  
  def index
    @logs = []
    @requests = Request.all
    
    @requests.each do |request|
      log = {
        :datetime => request.datetime,
        :user => request.user,
        :item_name => Item.find_by(:id => request.item_id).unique_name,
        :quantity => request.quantity,
        :status => request.status,
        :request_type => request.request_type
      }

      @logs.push(log)
    end
  end

  def create
    @request = Request.new(request_params)
  end

  private
    def request_params
      params.fetch(:request, {}).permit(:datetime, :item_id, :quantity, :request_type)
    end
end
