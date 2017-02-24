class LogsController < ApplicationController

  # TODO: no conscious log creation errr outside acquisition/destruction.
	before_action :check_logged_in_user

	def index
    # @logs = Log.filter(params.slice(:item_id, 
    #                                :quantity, 
    #                                :user_id, 
    #                                :request_type)
    #                  ).paginate(page: params[:page], per_page: 10)
    @logs = Log.all.paginate(page: params[:page], per_page: 10)
  if current_user.nil?
	
	end

	end

  def new
    @log = Log.new
  end

  def create
    @log = Log.new(log_params)
    # @log.item_id = params[:item][:id]
    # @item = @log.item

    #if !@item
    #  reject_to_new("Item does not exist") and return
    #elsif Log.oversubscribed?(@item, @log)
    #  reject_to_new("Oversubscribed!") and return
    #else
    save_form(@log)
    #  @item.update_by_subrequest(@log, @log.request_type)
    #  @item.save!
    #end
  end

  private
    def log_params
      params.fetch(:log, {}).permit(:user_id, :log_type)
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
