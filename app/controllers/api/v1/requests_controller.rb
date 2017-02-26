class Api::V1::RequestsController < BaseController

  before_action :authenticate_with_token!
  before_action :auth_by_check_requests_corresponds_to_current_user!, only: [:edit, :update, :destroy, :show]
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :requests, 'Requests'

  swagger_api :index do
    summary 'Returns all requests'
    notes 'These are some notes for everybody!'
    param :query, :page, :integer, :optional, "Page number"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :show do
    summary "Fetches a single request"
    param :path, :id, :integer, :required, "id"
    response :ok, "Success", :request
    response :unauthorized
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new request"
    notes 'Request types: disbursement, acquisition, destruction. Status: outstanding, approved, denied'
    param :form, :user_id, :number, :required, "User ID"
    param :form, :reason, :string, :required, "Reason"
    param_list :form, :request_type, :string, :required, "Request Type", ["disbursement", "acquisition", "destruction"]
    param_list :form, :status, :string, :required, "Status", ["cart", "outstanding", "approved", "denied"]
    param :form, :response, :string, :description, "Admin Response"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary 'Updates an existing request'
    notes 'Request types: disbursement, acquisition, destruction. Status: cart, outstanding, approved, denied'
    param :path, :id, :integer, :required, "id"
    param :form, :user_id, :number, :description, "User ID"
    param :form, :item_id, :number, :description, "Item ID"
    param :form, :reason, :string, :description, "Reason"
    param_list :form, :request_type, :string, :optional, "Request Type", ["disbursement", "acquisition", "destruction"]
    param_list :form, :status, :string, :optional, "Status", ["cart", "outstanding", "approved", "denied"]
    param :form, :response, :string, :description,  "Admin Response"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes a request"
    param :path, :id, :integer, :required, "id"
    response :unauthorized
    response :not_acceptable
  end

  def index
    respond_with Request.all
  end

  def show
    respond_with Request.find(params[:id])
  end

  def create
    req = Request.new(request_params)
    if req.save
      render json: req, status: 201, location: [:api, req]
    else
      render json: { errors: req.errors }, status: 422
    end
  end

  def update
    req = Request.find(params[:id])

    if req.update(request_params)
      render json: req, status: 200, location: [:api, req]
    else
      render json: { errors: req.errors }, status: 422
    end
  end 
  
  def destroy
    req = Request.find(params[:id])
    req.destroy
    head 204
  end

  private
    def request_params
      params.permit(:user_id, :item_id, :quantity, :reason, :status, :request_type, :response)
    end
end
