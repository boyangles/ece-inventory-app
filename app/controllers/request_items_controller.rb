class RequestItemsController < ApplicationController
  before_action :check_logged_in_user, :check_approved_user

  def index
  end

  # GET /requests/1
  def show
  end

  def new
    @request_item = RequestItem.new

    if !params[:item_id].blank?
      @request_item[:item_id] = params[:item_id]
    end

    # look for cart
    find_cart[:request_id]
    @request_item[:request_id] = find_cart[:request_id]


  end

  def create
    @request_item = RequestItem.new(request_item_params) #make private def later
    if @request_item.save
      redirect_to users_url   ## TODO: Redirect to cart page.
    else
      flash.now[:danger] = "You may not add this to the cart!"
      render 'new'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:request_item, {}).permit(:quantity, :item_id, :request_id)
  end

  def find_cart
    if Request.where(:user_id => current_user.id, :status => "cart").empty?
      # create cart
      Request.new(:status => "cart", :user_id => current_user, :reason => "TBD")
    else
      Request.where(:user_id => current_user.id, :status => "cart")
    end
  end

end
