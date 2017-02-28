class Api::V1::RequestsController < BaseController

  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :requests, 'Requests'

  swagger_api :create do
    summary "Creates a Request (Disbursement, Acquisition, Destruction)"
    notes "Specify your request type (must be one of: disbursement/acquisition/destruction). List items and corresponding quantities you want in the requests by entering in the following format: 'item1: 5, item2: 13, ...'"
    param_list :form, 'request[request_type]', :string, :required, "Request Type (disbursement/acquisition/destruction)", [:disbursement, :acquisition, :destruction]
    param :form, 'request[reason]', :string, :optional, "Reason for request"
    param :form, 'request[email]', :string, :required, "Email address of requesting user"
    param :query, :request_items, :string, :optional, "Example --> item1: 15, item2: 34, item15: 14"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  def create
    render_client_error("Email doesn't correspond to existing user", 422) and
        return unless User.exists?(:email => request_params[:email])
    @user = User.find_by(:email => request_params[:email])

    query_params = params.slice(:request_items)
    req_item_array, req_item_errors = key_value_query_string_to_hash_array(query_params[:request_items])

    render_client_error(req_item_errors, 422) and return unless req_item_errors.blank?

    req_item_array.each do |req_item|
      item_name = req_item[:key]
      item_quantity = req_item[:value]

      render_client_error("Item #{item_name} doesn't exist", 422) and
          return unless Item.exists?(:unique_name => item_name)
      render_client_error("Quantity #{item_quantity} is not an integer", 422) and
          return unless !!/\A\d+\z/.match(item_quantity)

      req_item[:key] = Item.find_by(:unique_name => item_name)
      req_item[:value] = item_quantity.to_i
    end

    case request_params[:request_type]
      when 'disbursement'
        handle_disbursement_creation(req_item_array, @user)
      when 'acquisition'
        auth_by_admin_privilege!
        handle_acquisition_creation(req_item_array, @user)
      when 'destruction'
        auth_by_admin_privilege!
        handle_destruction_creation(req_item_array, @user)
      else
        render_client_error("Request type is not disbursement/acquisition/destruction", 422) and return
    end
  end

  private
  def handle_disbursement_creation(req_item_array, user)
    if current_user_by_auth.privilege_student? && current_user_by_auth.id != user.id
      render_client_error("User #{user.email} is not self!", 422) and return
    end

    status = (current_user_by_auth.privilege_student?) ? 'outstanding' : 'approved'
    @req = Request.create({:user_id => user.id, :reason => request_params[:reason],
                           :status => status, :request_type => 'disbursement'})

    render_client_error(@req.errors, 422) and return unless @req

    req_item_array.each do |req_item|
      RequestItem.create({:request_id => @req.id,
                          :item_id => req_item[:key].id,
                          :quantity => req_item[:value]})
    end

    if !current_user_by_auth.privilege_student?
      request_valid, error_msg = @req.are_request_details_valid?

      if request_valid
        @req.request_items.each do |sub_request|
          item = Item.find(sub_request.item_id)
          item.update_by_subrequest(sub_request, @req.request_type)
          item.save!
        end
        render_request_with_sub_requests(@req, user)
      else
        @req.destroy!
        render_client_error(error_msg, 422) and return
      end
    else
      render_request_with_sub_requests(@req, user)
    end
  end

  private
  def handle_acquisition_creation(req_item_array, user)

  end

  private
  def handle_destruction_creation(req_item_array, user)

  end

  private
  def render_request_with_sub_requests(request, user)
    render :json => request.instance_eval {
        |req| {
          :user => user.email,
          :reason => req.reason,
          :request_type => req.request_type,
          :status => req.status,
          :sub_requests => req.request_items.map {
              |req_item| {
                :item => Item.find(req_item.item_id).unique_name,
                :quantity => req_item.quantity
            }
          }
      }
    }, status: 200
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
      params.fetch(:request, {}).permit(:user_id, :reason, :status, :request_type, :response, :email)
    end
end
