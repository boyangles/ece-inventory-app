class Api::V1::LogsController < BaseController
  respond_to :json

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
    params.fetch(:log, {}).permit(:item_id, :quantity, :user_id, :request_type)
  end
end