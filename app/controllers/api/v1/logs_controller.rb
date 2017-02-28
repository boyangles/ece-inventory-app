class Api::V1::LogsController < ApplicationController

  before_action :authenticate_with_token!, :auth_by_manager_privilege!
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :logs, 'Logs'

  swagger_api :index do
    summary 'Returns all Logs'
    notes 'These are some notes for everybody!'
    param :header, :Authorization, :string, :required, 'Authentication token'
    param :query, :user_search, :string, :optional, "User Name Search"
    param :query, :item_search, :string, :optional, "Item Name Search"
    param :query, :start_date, :string, :optional, "Start Date Search format : mm/dd/yyyy"
    param :query, :end_date, :string, :optional, "End Date Search, format : mm/dd/yyyy"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :show do
    summary "Fetches a single log"
    param :header, :Authorization, :string, :required, 'Authentication token'
    param :path, :id, :integer, :required, "id"
    response :ok, "Success", :log
    response :unauthorized
    response :not_found
  end


  def index
    if params[:user_search].blank? && params[:item_search].blank? && params[:start_date].blank? && params[:end_date].blank?
      respond_with Log.all
    else
      userLogs = Log.where(user_id: User.select(:id).where("username ILIKE ?", "%#{params[:user_search]}%"))
      users = Log.where(id: UserLog.select(:log_id).where(user_id: User.select(:id).where("username ILIKE ?", "%#{params[:user_search]}%")))
      itemLogs = Log.where(id: ItemLog.select(:log_id).where(item_id: Item.select(:id).where("unique_name ILIKE ?", "%#{params[:item_search]}%")))
      startLogs = Log.where("created_at >= :date", date: params[:start_date])
      endLogs = Log.where("created_at <= :date", date: params[:end_date])
      betweenDatesLogs = nil
      if params[:start_date] && params[:end_date]
        betweenDatesLogs = Log.where(created_at: params[:start_date]..params[:end_date])
      end

      if !params[:user_search].blank?
        firstLayer = Log.where(id: userLogs | users)
      end

      if !params[:item_search].blank? && !firstLayer.blank?
        secondLayer = Log.where(id: firstLayer & itemLogs)
      elsif !params[:item_search].blank?
        secondLayer = itemLogs
      else
        secondLayer = firstLayer
      end

      if !params[:start_date].blank? && !secondLayer.blank?
        thirdLayer = Log.where(id: secondLayer & startLogs)
      elsif !params[:start_date].blank?
        thirdLayer = startLogs
      else
        thirdLayer = secondLayer
      end

      if !params[:end_date].blank? && !thirdLayer.blank?
        fourthLayer = Log.where(id: thirdLayer & endLogs)
      elsif !params[:end_date].blank?
        fourthLayer = endLogs
      else
        fourthLayer = thirdLayer
      end

      respond_with Log.where(id: fourthLayer)
    end

  end

  def show
    respond_with Log.find(params[:id])
  end

  private
  def log_params
    params.fetch(:log, {}).permit(:user_id, :log_type)
  end

  private
  def render_client_error(error_hash, status_number)
    render json: {
        errors: error_hash
    }, status: status_number
  end
end