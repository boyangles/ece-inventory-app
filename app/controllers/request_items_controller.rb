class RequestItemsController < ApplicationController
  before_action :check_logged_in_user, :check_approved_user

  def index
    @request_items = RequestItem.paginate(page: params[:page], per_page: 10)
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
    # find_cart
    find_cart_id
    @request_item[:request_id] = @request.id
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


  #:user_id => current_user.id,
  def find_cart_id
    # if Request.where( :status => "cart").none?
    #   # create cart
    #   return Request.new(:status => "cart", :user_id => current_user, :reason => "TBD").id
    # else
    #   return Request.where(:user_id => current_user.id, :status => "cart").id
    # end

    @request = Request.where(:status => "cart", :user_id => current_user.id).first
    if @request.nil?
      @request = Request.new(:status => "cart", :user_id => current_user.id, :reason => "TBD", :request_type => "disbursement")
    end

    # if Request.where(:status => 3).empty?
    #   @request = Request.new(:status => 3, :user_id => current_user.id, :reason => "TBD", :request_type => "disbursement")
    # else
    #   @request = Request.where(:status => 3)
    # end

    if !@request.save(:validate => false)
      flash[:error] = "jaklsdfkljadslfjklasjdlfjklasjdflajlksdfjlkasjdfkljaskldf"
    end

  end

end
