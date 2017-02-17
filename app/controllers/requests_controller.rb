class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]
  before_action :check_logged_in_user
  before_action :check_requests_corresponds_to_current_user, only: [:edit, :update, :destroy, :show]

  # before_action :request_index_by_admin, only: [ :index ]          #maybe

  # GET /requests
  def index
    filter_params = params.slice(:status)

    if !current_user.privilege_admin?
      filter_params[:user_id] = current_user.id
    end

    @requests = Request.filter(filter_params).paginate(page: params[:page], per_page: 10)
  end

  # GET /requests/1
  def show
    @request = Request.find(params[:id])
   
	  @user = @request.user
  end

  # GET /requests/new
  # Delete this?? soon-ish, plus edit routes.
  # def new
  #   @request = Request.new
  #
  #   # if !params[:item_id].blank?
  #   #   @request[:item_id] = params[:item_id]
  #   # end
  #   # @item = @request.items
  #
  # end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
    @user = @request.user
		3.times {@request.request_items.build }
  end

  # POST /requests
	# OBSOLETE???
  def create
    @request = Request.new(request_params)
    @request.user_id = params[:user] ? params[:user][:id] : @request.user_id

    if !@request.approved?
      save_form(@request) and return
    end

    if !@item
      reject_to_new("Item does not currently exist") and return
    elsif Request.oversubscribed?(@item, @request)
      reject_to_new("Oversubscribed!") and return
    else
      save_form(@request)
      @item.update_by_request(@request)
      @item.save!

      @log = Log.new(log_params)
      @log.user_id = @request.user_id
      @log.save!
    end
  end

  # PATCH/PUT /requests/1
	# TODO: Can only update cart/outstanding - can't update approved/denied
  def update
    @request.user_id = params[:user] ? params[:user][:id] : @request.user_id
    
    if !@request.has_status_change_to_approved?(request_params)
			update_form(@request, request_params) and return
    end
    
    @request.request_items.each do |req_item| 
    	@item = Item.find(req_item.item_id)
			if !@item
      	reject_to_edit(@request, "Item does not currently exist") and return
    	elsif Request.oversubscribed?(@item, @request)
      	reject_to_edit(@request, "Oversubscribed!") and return
    	else
      	update_form(@request, request_params)

				@item.update_by_request(@request)
      	@item.save!

      	@log = Log.new(log_params)
      	@log.user_id = @request.user_id
      	@log.save!
	
				# create a new cart object and update user
				# create_new_cart()
				# @user_cart = UserCart.where(:user_id => current_user.id).take
				# @user_cart.cart_id = @cart.id
    	end
  	end
	end

  # DELETE /requests/1
  def destroy
    
    if (@request.destroy)
      flash[:success] = "Request destroyed!"
    else
      flash[:danger] = "Unable to destroy request!"
    end

    redirect_to requests_url
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    def save_form(req)
      if req.save
        flash[:success] = "Request created"
        redirect_to(requests_path)
      else
        flash.now[:danger] = "Request could not be successfully saved"
        render 'new'
      end
    end

    def update_form(req, params)
      if req.update(params)
        flash[:success] = "Operation successful!"
      else
        flash[:danger] = "Operation failed"
      end
		  redirect_to request_path(req)
    end

    def reject_to_new(msg)
      flash.now[:danger] = msg
      render 'new'
    end

    def reject_to_edit(request, msg)
      flash[:danger] = msg
      redirect_to request_path(request)
    end

    def request_index_by_admin
      if !current_user
        redirect_to root_url
      end
    end

		def create_new_cart
			@cart = Request.new(:status => "cart", :user_id => current_user.id, :reason => "tbd")
		end


    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      # params.fetch(:request, {}).permit(:user_id, :item_id, :reason, :status, :request_type, :response)
      params.fetch(:request, {}).permit(:user_id, :reason, :status, :request_type, :response, request_items_attributes: [:id, :quantity])
    end

    def log_params
      params.fetch(:request, {}).permit(:item_id, :user_id, :request_type)
    end

end
