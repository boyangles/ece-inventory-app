class Api::V1::RequestsController < Application Controller
  respond_to :json

  def destroy
    request = Request.find(params[:id])
    request.destroy
    head 204
  end
end
