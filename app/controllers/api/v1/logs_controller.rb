class Api::V1::LogsController < BaseController

  before_action :authenticate_with_token!, :auth_by_manager_privilege!
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :logs, 'Logs'

  swagger_api :index do
    summary 'Returns all Logs'
    notes 'These are some notes for everybody!'
    param :query, :page, :integer, :optional, "Page number"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :show do
    summary "Fetches a single log"
    param :path, :id, :integer, :required, "id"
    response :ok, "Success", :log
    response :unauthorized
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new log"
    param :form, :quantity, :number, :required, "Quantity"
    param :form, :user_id, :string, :required, "User ID"
    param :form, :item_id, :string, :required, "Item ID"
    param_list :form, :request_type, :string, :required, "Request Type", ["disbursement", "acquisition", "destruction"]
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing log"
    param :path, :id, :integer, :required, "id"
    param :form, :quantity, :number, "Quantity"
    param :form, :user_id, :string, "User ID"
    param :form, :item_id, :string, "Item ID"
    param_list :form, :request_type, :string, "Request Type", ["disbursement", "acquisition", "destruction"]
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes a log"
    param :path, :id, :integer, :required, "id"
    response :unauthorized
    response :not_acceptable
  end


  def index
    respond_with Log.all
  end

  def show
    respond_with Log.find(params[:id])
  end

  def create
    log = Log.new(log_params)
    if log.save
      render json: log, status: 201, location: [:api, log]
    else
      render json: { errors: log.errors }, status: 422
    end
  end

  def update
    log = Log.find(params[:id])
    if log.update(log_params)
      render json: log, status: 200, location: [:api, log]
    else
      render json: { errors: log.errors }, status: 422
    end
  end

  def destroy
    log = Log.find(params[:id])
    log.destroy
    head 204
  end

  private
  def log_params
    params.permit(:item_id, :quantity, :user_id, :request_type)
  end
end