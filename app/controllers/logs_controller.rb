class LogsController < ApplicationController
  #TODO Add before_action (i.e. only admins can access logs)
  before_action :check_logged_in_user, only: [:index]
  before_action :check_admin_user, only: [:index]

  def index
    @logs = Log.filter(params.slice(:datetime, 
                                    :item_id, 
                                    :quantity, 
                                    :user_id, 
                                    :request_type))
    
    @detailed_logs = []
    
    @logs.each do |log|
      detailed_log = {
        :datetime => log.datetime,
        :user => User.find_by(:id => log.user_id),
        :item => Item.find_by(:id => log.item_id),
        :quantity => log.quantity,
        :request_type => log.request_type
      }

      @detailed_logs.push(detailed_log)
    end
  end

  def create
    new_log = create_log_params
    
    datetime = new_log[:datetime]
    item_id = Item.find_by(:unique_name => new_log[:item_name]).id
    quantity = new_log[:quantity]
    user_id = User.find_by(:username => new_log[:username]).id
    # request_type = new_log.request_type
    request_type = 'disbursement'

    transformed_params = {
      datetime: datetime,
      item_id: item_id,
      quantity: quantity,
      user_id: user_id,
      request_type: request_type
    }

    @log = Log.new(transformed_params)

    if @log.save
      render json: @log
    else
      render json: @log.errors, status: :unprocessable_entity
    end
  end

  private
    def create_log_params
      params.fetch(:log, {}).permit(:datetime, :item_name, :quantity, :username, :request_type)
    end
  
    def log_params
      params.fetch(:log, {}).permit(:datetime, :item_id, :quantity, :user_id, :request_type)
    end
end
