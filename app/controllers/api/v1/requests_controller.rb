class Api::V1::RequestsController < BaseController

  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :requests, 'Requests'

  swagger_api :create do
    summary "Creates a Request (Disbursement, Acquisition, Destruction)"
    notes "Specify your request type (must be one of: disbursement/acquisition/destruction). List items and corresponding quantities you want in the requests by entering in the following format: 'item1: 5, item2: 13, ...'"
    param :form, 'request[request_type]', :string, :required, "Request Type (disbursement/acquisition/destruction)"
    param :form, 'request[reason]', :string, :optional, "Reason for request"
    param :form, 'request[email]', :string, :required, "Email address of requesting user"
  end

  private
  def set_request
    @request = Request.find(params[:id])
  end

  private
  def render_404_if_request_unknown
    render json: { errors: 'User not found!' }, status: 404 unless
        Request.exists?(params[:id])
  end

  private
    def request_params
      params.fetch(request, {}).permit(:user_id, :item_id, :quantity, :reason, :status, :request_type, :response)
    end
end
