class Api::V1::RequestsController < BaseController
  respond_to :json

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
      params.fetch(:request, {}).permit(:user_id, :item_id, :quantity, :reason, :status, :request_type, :response)
    end
end
