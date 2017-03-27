class SubscribersController < ApplicationController

  before_action :check_logged_in_user
  before_action :check_manager_or_admin

  before_action :set_subscriber, only: [:destroy]

  def index

    # not_deactivated_subscribers = Subscriber.user.where.not(status: 'deactivated')
    ## Need to filter out all unsubscribed users. How to do this??? Ask austin
    # Subscriber.filter(:user.status => 'approved')
    @subscribers = Subscriber.paginate(page: params[:page], per_page: 10)
  end

  def new
    @subscriber = Subscriber.new
  end


  ## Making this work for now! May not have edit method later!
  def edit

  end

  def destroy
    if (@subscriber.destroy)
      flash[:success] = "Subscriber deleted!"
    else
      flash[:danger] = "Unable to destroy subscriber!"
    end
    redirect_to subscribers_path
  end

  def create
    if Subscriber.where(:user_id => current_user.id).blank?
         # no user record for this id
      @subscriber = Subscriber.new(sub_params)
      @subscriber.user = current_user
      if @subscriber.save
        flash[:success] = "Subscriber saved"
        redirect_to subscribers_path
      else
        @subscribers = Subscriber.paginate(page: params[:page], per_page: 10)
        flash[:danger] = "Subscriber not saved"
        render :index
      end
    else
         # at least 1 record for this user
    end
  end


  private
  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sub_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:subscriber, {}).permit(:user_id)
  end

  def user_active
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:subscriber, {}).permit(:user_id)
  end

end
