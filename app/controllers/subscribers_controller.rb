class SubscribersController < ApplicationController

  def index
    @subscribers = Subscriber.paginate(page: params[:page], per_page: 10)
  end

  def new
    @subscriber = Subscriber.new
  end

  def destroy
    Subscriber.find(params[:id]).destroy
    flash[:success] = "Suscriber deleted!"
    redirect_to subscribers_path
  end

  def create
    @subscriber = Subscriber.new(sub_params)
    if @subscriber.save
      flash[:success] = "Subscriber saved"
      redirect_to subscribers_path
    else
      @subscribers = Subscriber.paginate(page: params[:page], per_page: 10)
      flash[:danger] = "Subscriber not saved"
      render :index
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def sub_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:subscriber, {}).permit(:name)
  end

end
