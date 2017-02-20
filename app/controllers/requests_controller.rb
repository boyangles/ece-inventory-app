class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]
  before_action :check_logged_in_user
  before_action :check_requests_corresponds_to_current_user, only: [:edit, :update, :destroy, :show]

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

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
    @user = @request.user
  end

  # PATCH/PUT /requests/1
  def update
    if params[:user]
      @request.user_id = params[:user][:id]
    end

    if @request.has_status_change_to_approved?(request_params)
      request_valid, error_msg = @request.are_request_details_valid?

      if request_valid
        update_to_index(@request, request_params)

        @request.request_items.each do |sub_request|
          @item = Item.find(sub_request.item_id)
          @item.update_by_subrequest(sub_request, @request.request_type)
          @item.save!
        end
      else
        reject_to_edit(@request, error_msg)
      end
    else
      update_to_index(@request, request_params)
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

  def update_to_index(req, params)
    req.update_attributes!(params)

    flash[:success] = "Operation successful!"
    redirect_to request_path(req)
    # if req.update(params)
    #   flash[:success] = "Operation successful!"
    #   redirect_to request_path(req)
    # else
    #   flash[:danger] = "Operation failed"
    #   redirect_to request_path(req)
    # end
  end

  def reject_to_edit(request, msg)
    flash[:danger] = msg
    redirect_to request_path(request)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    params.fetch(:request, {}).permit(:user_id,
                                      :reason,
                                      :status,
                                      :request_type,
                                      :response,
                                      request_items_attributes: [:id, :quantity])
  end

  def log_params
    params.fetch(:request, {}).permit(:item_id,
                                      :user_id,
                                      :request_type)
  end

end
