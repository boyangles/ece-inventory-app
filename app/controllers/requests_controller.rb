class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]



  before_action :check_logged_in_user, only:[:index]

  # before_action :request_index_by_admin, only: [ :index ]          #maybe
  # Security issue: only admin users can delete users        #maybe

  # GET /requests
  # GET /requests.json
  def index
    filter_params = params.slice(:status)

    if !current_user.privilege_admin?
      filter_params[:user] = current_user.username
    end

    @requests = Request.filter(filter_params)
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
    @request = Request.find(params[:id])
  end

  # GET /requests/new
  def new
    @request = Request.new
    
    if !params[:item_name].blank?
      @request[:item_name] = params[:item_name]
    end
    
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(request_params)
    @user = current_user

    # Set default values for requests:
    @request.user = @user.username
    @request.datetime = Time.now
    @request.status = "outstanding"
    # @request.request_type = ??? what is this?


    respond_to do |format|
      if @request.save
        format.html { redirect_to @request, notice: 'Request was successfully created.' }
        format.json { render :show, status: :created, location: @request }
      else
        format.html { render :new }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    # TODO: Delete this sudo-code
    # checkIfAdminRequestStatusUpdate(@request, updated_params)
    # checkIfItemExists(@request)
    # checkIfItemQuantityWillBeNegative(@request, corresponding item)
    # If request is approved, create a log automatically... if not, then don't create one
    # Decrease item quantity by request quantity
    # Display error on the show page if request fails

    # editRequest(@request)

    if request_is_admin_status_update?(@request, request_params)
      item_name = @request.item_name
      if !item_exists?(item_name)
        flash[:error] = "Item does not exist anymore."
        redirect_to request_path(@request)
      elsif !item_quantity_sufficient?(@request, item_name)
        flash[:error] = "Item quantity not sufficient to fulfill request."
        redirect_to request_path(@request)
      else
        flash[:success] = "Request approved"
        edit_request(@request)

        item = Item.find_by(:unique_name => item_name) # should be unique
        item.quantity = item.quantity - @request.quantity
        item.save!
      end

    else
      # redirect_to root_url
      edit_request(@request)
    end

  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to requests_url, notice: 'Request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  
 
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    def findRequestbyUser(user)
       Request.find_by_user(user.username)
    end

    def request_index_by_admin
      if !current_user
        redirect_to root_url
      # elsif !current_user.privilege_admin?
      #   username = current_user.username
      #   redirect_to requests_path, user: username
      end
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      params.fetch(:request, {}).permit(:datetime, :user, :item_name, :quantity, :reason, :status, :request_type, :instances)
    end
end
