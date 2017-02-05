class LogsController < ApplicationController
  #TODO Add before_action (i.e. only admins can access logs)
  before_action :check_logged_in_user, :check_admin_user

  def index
    @logs = Log.filter(params.slice(:datetime, 
                                    :item_name, 
                                    :quantity, 
                                    :user, 
                                    :request_type))
    
  end

  def new
    @log = Log.new
  end

  def create
    new_log_params = log_params
    new_log_params[:item_name] = params[:item][:unique_name]
    @log = Log.new(new_log_params)

    # TODO: Make disbursement/acquisition/destruction decrement actual item quantities

    if @log.save
      flash[:success] = "Log succesfully saved!"
      redirect_to logs_path
    else
      render 'new'
    end
  end

  private
    def log_params
      params.fetch(:log, {}).permit(:datetime, :item_name, :quantity, :user, :request_type)
    end
end
