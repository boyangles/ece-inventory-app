class Api::V1::RequestsController < BaseController

  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:decision]
  before_action :render_404_if_request_unknown, only: [:show, :decision, :update_general, :create_req_items, :destroy_req_items]
  before_action :set_request, only: [:show, :decision, :update_general, :create_req_items, :destroy_req_items]

  before_action -> { render_422_if_request_not_outstanding_and_disbursement!(params[:id]) }, only: [:decision, :update_general, :create_req_items, :destroy_req_items]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:decision, :update_general, :create_req_items, :destroy_req_items].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :requests, 'Requests'

  swagger_api :create do
    summary "Creates a Request"
    notes 'List items and corresponding quantities you want in the requests. Request Type must be either "loan" or "disbursement"'
    param :form, 'request[reason]', :string, :optional, "Reason for request"
    param :form, 'request[email]', :string, :required, "Email address of user to request for"
    param :query, :request_items, :string, :required, 'Example --> [{"item_name": "item1", "quantity_loan": 15, "quantity_disburse": 13, "request_type": "loan"}, ...]'
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :decision do
    summary "Approve or Deny a Disbursement that is Outstanding"
    param :path, :id, :integer, :required, "Request ID"
    param_list :form, 'request[status]', :string, :required, "Status to update to (approved/denied)"
    param :form, 'request[response]', :string, :optional, "Response"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :update_general do
    summary "Update general attributes for your own requests"
    param :path, :id, :integer, :required, "Request ID"
    param :form, 'request[reason]', :string, :optional, "Reason"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :create_req_items do
    summary "Creates new subrequests for items on your own oustanding requests"
    param :path, :id, :integer, :required, "Request ID"
    param :query, :request_items, :string, :optional, "Example --> item1: 15, item2: 34, item15: 14"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :destroy_req_items do
    summary "Removes subrequests for items on your own oustanding requests"
    param :path, :id, :integer, :required, "Request ID"
    param :query, :request_items, :string, :optional, "Example --> item1, item2, item3, ..."
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :show do
    summary "Shows a particular request and its subrequests"
    param :path, :id, :integer, :required, "Request ID"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :index do
    summary "Shows all requests (self for students)"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :update do
    summary "Deprecated in favor of other PATCH requests"
  end

  def index
    if current_user_by_auth.privilege_student?
      requests = Request.where(:user_id => current_user_by_auth.id)

      render :json => requests.map {
          |req| {
            :user => req.user.email,
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
    else
      requests = Request.all

      render :json => requests.map {
          |req| {
            :id => req.id,
            :user => req.user.email,
            :reason => req.reason,
            :request_type => req.request_type,
            :status => req.status
        }
      }, status: 200
    end
  end

  def show
    if current_user_by_auth.privilege_student? && @request.user_id != current_user_by_auth.id
      render_client_error("Cannot view other peoples' requests", 401) and return
    end

    render_request_with_sub_requests(@request, @request.user)
  end

  def create
    user = User.find_by(:email => request_params[:email])
    query_params = params.slice(:request_items)

    render_client_error("Invalid JSON format", 422) and return unless valid_json?(query_params[:request_items])
    req_items = JSON.parse(query_params[:request_items])
    render_client_error("JSON format must be array", 422) and return unless req_items.kind_of?(Array)
    begin
      @request = current_user_by_auth.make_request(subrequests: req_items, reason: request_params[:reason], requested_for: user)
      render_request_with_sub_requests(@request, @request.user)
    rescue Exception => e
      render_client_error(e.message, 422) and return
    end
  end

  def decision
    case request_params[:status]
      when 'approved'
        request_valid, error_msg = @request.are_request_details_valid?

        if request_valid
          if !@request.update(request_params)
            render_client_error(@request.errors, 422) and return
          end

          render_request_with_sub_requests(@request, @request.user)
        else
          render_client_error(error_msg, 422) and return
        end
      when 'denied'
        if @request.update(request_params)
          render_request_with_sub_requests(@request, @request.user)
        else
          render_client_error(@request.errors, 422)
        end
      else
        render_client_error("Enum incorrect: #{request_params[:status]}. Must be approved/denied", 422)
    end

  end

  def update_general
    render_client_error("Cannot update request that is not your own!", 401) and
        return unless @request.user_id == current_user_by_auth.id

    if @request.update(request_params)
      render_request_with_sub_requests(@request, @request.user)
    else
      render_client_error(@request.errors, 422)
    end
  end

  def create_req_items
    render_client_error("Cannot update request that is not your own!", 401) and
        return unless @request.user_id == current_user_by_auth.id

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

      if RequestItem.exists?(:request_id => @request.id, :item_id => req_item[:key].id)
        render_client_error("Item to Request Association already exists", 422) and return
      end
    end

    req_item_array.each do |req_item|
      RequestItem.create(:request_id => @request.id,
                          :item_id => req_item[:key].id,
                          :quantity => req_item[:value])
    end

    render_request_with_sub_requests(@request, @request.user)
  end

  def destroy_req_items
    render_client_error("Cannot update request that is not your own!", 401) and
        return unless @request.user_id == current_user_by_auth.id

    query_params = params.slice(:request_items)
    req_item_array = (query_params[:request_items].blank?) ? [] : query_params[:request_items].split(",").map(&:strip)

    items_list = []

    req_item_array.each do |req_item|
      item_name = req_item

      render_client_error("Item #{item_name} doesn't exist", 422) and
          return unless Item.exists?(:unique_name => item_name)

      item = Item.find_by(:unique_name => item_name)
      items_list.push(item)

      render_client_error("Item to Request Association doesn't exists", 422) and
          return unless RequestItem.exists?(:request_id => @request.id, :item_id => item.id)
    end

    items_list.each do |my_item|
      RequestItem.find_by(:request_id => @request.id,
                       :item_id => my_item.id).destroy
    end

    render_request_with_sub_requests(@request, @request.user)
  end

  private
  def render_request_with_sub_requests(request, user)
    render :json => request.instance_eval {
        |req| {
          :user => user.email,
          :reason => req.reason,
          :status => req.status,
          :requested_for => User.find(req.user_id).username,
          :sub_requests => req.request_items.map {
              |req_item| {
                :item => Item.find(req_item.item_id).unique_name,
                :quantity_on_loan => req_item.quantity_loan,
                :quantity_disbursed => req_item.quantity_disburse,
                :quantity_returned => req_item.quantity_return,
                :request_type => req_item.request_type
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
    render json: { errors: 'Request not found!' }, status: 404 unless
        Request.exists?(params[:id])
  end

  private
  def render_422_if_request_not_outstanding_and_disbursement!(request_id)
    req = Request.find(request_id)

    render json: { errors: 'Request is not outstanding and disbursement' }, status: 422 unless
        req && req.outstanding? && req.disbursement?
  end

  private
    def request_params
      params.fetch(:request, {}).permit(:user_id, :reason, :status, :request_type, :response, :email)
    end
end
