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


  def index
    respond_with Log.all
  end

  def show
    respond_with Log.find(params[:id])
  end

  private
  def log_params
    params.permit(:user_id, :log_type)
  end
end