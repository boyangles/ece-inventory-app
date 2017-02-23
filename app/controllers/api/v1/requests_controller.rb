class Api::V1::RequestsController < BaseController
  # authentication_actions = [:index, :show, :update, :destroy]

  before_action :authenticate_with_token!
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  # TODO: Still needs admin stuff on most of these methods I believe

  respond_to :json

  swagger_controller :requests, 'Requests'

  # authentication_actions.each do |api_action|
  #   swagger_api api_action do
  #     param :header, :Authorization, :required, "Authorization Token"
  #   end
  # end

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
    param :form, :user_id, :number, :required, "User ID"
    param :form, :item_id, :number, :required, "Item ID"
    param :form, :quantity, :number, :required, "Quantity"
    param :form, :reason, :string, :required, "Reason"
    param_list :form, :request_type, :string, :required, "Request Type", ["disbursement", "acquisition", "destruction"]
    param_list :form, :status, :string, :required, "Status", ["outstanding", "approved", "denied"]
    param :form, :response, :string, :required, "Response"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing request"
    param :path, :id, :integer, :required, "id"
    param :form, :user_id, :number, "User ID"
    param :form, :item_id, :number, "Item ID"
    param :form, :quantity, :number, "Quantity"
    param :form, :reason, :string, "Reason"
    param_list :form, :request_type, :string, "Request Type", ["disbursement", "acquisition", "destruction"]
    param_list :form, :status, :string, "Status", ["outstanding", "approved", "denied"]
    param :form, :response, :string, "Response"
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
