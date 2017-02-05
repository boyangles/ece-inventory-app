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

    @item = Item.find_by(:unique_name => @log.item_name)

    # TODO: Make disbursement/acquisition/destruction decrement actual item quantities
    if @log.disbursement?
      if @item.quantity >= @log.quantity
        if @log.save
          flash[:success] = "Log succesfully saved!"
          redirect_to logs_path

          @item.quantity = @item.quantity - @log.quantity
          @item.save!
        else
          flash[:danger] = "Unable to save!"
          render 'new' and return
        end
      else
          flash[:danger] = "Not enough item quantity"
          render 'new' and return
      end
    elsif @log.destruction?
      if @item.quantity >= @log.quantity
        if @log.save
          flash[:success] = "Log succesfully saved!"
          redirect_to logs_path
  
          @item.quantity = @item.quantity - @log.quantity
          @item.save!
        else
          flash[:danger] = "Unable to save!"
          render 'new' and return
        end
      else
          flash[:danger] = "Not enough item quantity"
          render 'new' and return
      end
    else # @log.acquisition?
      if @log.save
        flash[:success] = "Log succesfully saved!"
        redirect_to logs_path


        @item.quantity = @item.quantity + @log.quantity
        @item.save!
      else
        flash[:danger] = "Unable to save!"
        render 'new' and return
      end
    end

  end

  private
    def log_params
      params.fetch(:log, {}).permit(:datetime, :item_name, :quantity, :user, :request_type)
    end
end
