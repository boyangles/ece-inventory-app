class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]
  before_action :check_logged_in_user, :check_approved_user


  # before_action :request_index_by_admin, only: [ :index ]          #maybe

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
    @request.user = (params[:user]) ? params[:user][:username] : current_user.username

    @item = Item.find_by(:unique_name => @request.item_name)

    # Create a denied request or an outstanding request
    if !@request.approved?
      save_form(@request) and return
    end

    if !@item
      reject_to_new("Item does not currently exist") and return
    elsif @request.oversubscribed?(@item)
      reject_to_new("Oversubscribed!") and return
    end

    save_form(@request)
    @item.update_by_request(@request)
    @item.save!

    @log = new_log_by_params_hash(@request, log_params)
    @log.save!
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    if request_is_admin_status_update?(@request, request_params)
      item_name = @request.item_name
      if !item_exists?(item_name)
        flash[:danger] = "Item does not exist anymore."
        redirect_to request_path(@request)
      elsif !item_quantity_sufficient?(@request, item_name)
        flash[:danger] = "Item quantity not sufficient to fulfill request."
        redirect_to request_path(@request)
      else
        flash[:success] = "Request approved"
        edit_request(@request)

        item = Item.find_by(:unique_name => item_name) # should be unique
        item.quantity = item.quantity - @request.quantity
        item.save!

        new_log_params = log_params
        new_log_params[:datetime] = log_params[:datetime] ? log_params[:datetime] : @request.datetime
        new_log_params[:item_name] = log_params[:item_name] ? log_params[:item_name] : @request.item_name
        new_log_params[:quantity] = log_params[:quantity] ? log_params[:quantity] : @request.quantity
        new_log_params[:request_type] = log_params[:request_type] ? log_params[:request_type] : @request.request_type
        new_log_params[:user] = params[:user] ? params[:user][:username] : @request.user

        new_log = Log.new(new_log_params)
        new_log.save!
      end

    else
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

    def save_form(req)
      if req.save
        flash[:success] = "Request created"
        redirect_to(requests_path)
      else
        render 'new'
      end
    end

    def reject_to_new(msg)
      flash[:danger] = msg
      render 'new'
    end

    def new_log_by_params_hash(request, log_params)
      new_log_params = log_params
      new_log_params[:datetime] = log_params[:datetime] ? log_params[:datetime] : request.datetime
      new_log_params[:item_name] = log_params[:item_name] ? log_params[:item_name] : request.item_name
      new_log_params[:quantity] = log_params[:quantity] ? log_params[:quantity] : request.quantity
      new_log_params[:request_type] = log_params[:request_type] ? log_params[:request_type] : request.request_type
      new_log_params[:user] = params[:user] ? params[:user][:username] : request.user

      return Log.new(new_log_params)
    end

    def request_index_by_admin
      if !current_user
        redirect_to root_url
      end
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      params.fetch(:request, {}).permit(:datetime, :user, :item_name, :quantity, :reason, :status, :request_type, :response)
    end

    def log_params
      params.fetch(:request, {}).permit(:datetime, :item_name, :quantity, :user, :request_type)
    end
end
