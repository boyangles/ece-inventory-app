class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]
  before_action :check_logged_in_user, :check_approved_user


  # before_action :request_index_by_admin, only: [ :index ]          #maybe

  # GET /requests
  def index
    filter_params = params.slice(:status)

    if !current_user.privilege_admin?
      filter_params[:user_id] = current_user.user_id
    end

    @requests = Request.filter(filter_params)
  end

  # GET /requests/1
  def show
    @request = Request.find(params[:id])
    @item = Item.find(@request.item_id)
    @user = User.find(@request.user_id)
  end

  # GET /requests/new
  def new
    @request = Request.new
    
    if !params[:item_id].blank?
      @request[:item_id] = params[:item_id]
    end
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
    @item = Item.find(@request.item_id)
    @user = User.find(@request.user_id)
  end

  # POST /requests
  def create
    @request = Request.new(request_params)
    @request.user_id = params[:user] ? params[:user][:id] : @request.user_id

    @item = Item.find(@request.item_id)

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
  def update
    @request.user_id = params[:user] ? params[:user][:id] : @request.user_id
    @item = Item.find(@request.item_id)
    
    if !@request.has_status_change_to_approved?(request_params)
      update_form(@request, request_params) and return
    end
    
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
        redirect_to requests_path
      else
        flash[:danger] = "Operation failed"
        redirect_to request_path(req)
      end
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
    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      params.fetch(:request, {}).permit(:datetime, :user_id, :item_id, :quantity, :reason, :status, :request_type, :response)
    end

    def log_params
      params.fetch(:request, {}).permit(:datetime, :item_id, :quantity, :user_id, :request_type)
    end
end
