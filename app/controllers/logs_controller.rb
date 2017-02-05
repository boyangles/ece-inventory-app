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
    @log = Log.new(log_params)
    @log.item_name = params[:item][:unique_name]

    @item = Item.find_by(:unique_name => @log.item_name)
    
    if !@item
      reject_to_new("Item does not exist") and return
    elsif Log.oversubscribed?(@item, @log)
      reject_to_new("Oversubscribed!") and return
    else
      save_form(@log)
      @item.update_by_request(@log)
      @item.save!
    end
  end

  private
    def log_params
      params.fetch(:log, {}).permit(:datetime, :item_name, :quantity, :user, :request_type)
    end

    def save_form(log)
      if log.save
        flash[:success] = "Log succesfully saved!"
        redirect_to(logs_path)
      else
        flash.now[:danger] = "Log could not be successfully saved"
        render 'new'
      end
    end

    def reject_to_new(msg)
      flash.now[:danger] = msg
      render 'new'
    end
end
