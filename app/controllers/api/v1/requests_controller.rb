class Api::V1::RequestsController < BaseController

  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:decision, :create_req_items, :destroy_req_items, :update_req_items, :return_req_items, :index_subrequests]
  before_action :render_404_if_request_unknown, only: [:show, :decision, :update_general, :create_req_items, :destroy_req_items, :update_req_items, :return_req_items]
  before_action :set_request, only: [:show, :decision, :update_general, :create_req_items, :destroy_req_items, :update_req_items, :return_req_items]

  before_action -> { render_422_if_request_not_outstanding!(params[:id]) }, only: [:decision, :update_general] # :create_req_items, :destroy_req_items, :update_req_items, :return_req_items

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:decision, :update_general, :create_req_items, :destroy_req_items, :update_req_items, :return_req_items, :index_subrequests].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :requests, 'Requests'

  swagger_api :create do
    summary "Creates a Request"
    notes 'List items and corresponding quantities you want in the requests.'
    param :form, 'request[reason]', :string, :optional, "Reason for request"
    param :form, 'request[email]', :string, :required, "Email address of user to request for"
    param :query, :request_items, :string, :required, 'Example --> [{"item_name": "item1", "quantity_loan": 15, "quantity_disburse": 13}, ...]'
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
    summary 'Creates new subrequests for existing requests.'
    param :path, :id, :integer, :required, "Request ID"
    param :query, :request_items, :string, :required, 'Example --> [{"item_name": "item1", "quantity_loan": 15, "quantity_disburse": 13}, ...]'
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :destroy_req_items do
    summary 'Deletes subrequests for existing requests.'
    param :path, :id, :integer, :required, "Request ID"
    param :query, :request_items, :string, :required, 'Example --> ["item1", "item2", ...]'
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :update_req_items do
    summary 'Updates new subrequests for existing requests.'
    param :path, :id, :integer, :required, "Request ID"
    param :query, :request_items, :string, :required, 'Example --> [{"item_name": "item1", "quantity_loan": 15, "quantity_disburse": 0}, ...]'
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :return_req_items do
    summary 'Returns specific amounts for requested items'
    param :path, :id, :integer, :required, "Request ID"
    param :query, :request_items, :string, :required, 'Example --> [{"item_name": "item1", "quantity_return": 15}, ...]'
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

  swagger_api :index_subrequests do
    summary "Shows all or specified subrequests"
    param :query, :item_name, :string, :optional, "Item Name"
    param :query, :username, :string, :optional, "Username"
    param :query, :req_type, :string, :optional, "Request Type (loan/disbursement/mixed)"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  def index
    requests = (current_user_by_auth.privilege_student?) ?
        Request.where(:user_id => current_user_by_auth.id) : Request.all
    render_multiple_requests(requests)
  end

  def index_subrequests
    filter_params = params.slice(:item_name, :username, :req_type)
    item_id = (Item.exists?(:unique_name => filter_params[:item_name])) ?
        Item.find_by(:unique_name => filter_params[:item_name]).id : -1
    user_id = (User.exists?(:username => filter_params[:username])) ?
        User.find_by(:username => filter_params[:username]).id : -1

    request_items = RequestItem.all
    request_items = request_items.filter({:item_id => item_id}) unless filter_params[:item_name].blank?
    request_items = request_items.filter({:user_id => user_id}) unless filter_params[:username].blank?
    request_items = request_items.filter({:request_type => filter_params[:req_type]}) unless filter_params[:req_type].blank?

    render :json => request_items, status: 200
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
    begin
      @request.update!(request_params)
      render_request_with_sub_requests(@request, @request.user)
    rescue Exception => e
      render_client_error(e.message, 422) and return
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
    query_params = params.slice(:request_items)
    render_client_error("Invalid JSON format", 422) and return unless valid_json?(query_params[:request_items])
    req_items = JSON.parse(query_params[:request_items])
    render_client_error("JSON format must be array", 422) and return unless req_items.kind_of?(Array)

    begin
      updated_request = current_user_by_auth.add_additional_subrequests(@request, req_items)
      render_request_with_sub_requests(updated_request, updated_request.user)
    rescue Exception => e
      render_client_error(e.message, 422) and return
    end
  end

  def destroy_req_items
    query_params = params.slice(:request_items)
    render_client_error("Invalid JSON format", 422) and return unless valid_json?(query_params[:request_items])
    req_items = JSON.parse(query_params[:request_items])
    render_client_error("JSON format must be array", 422) and return unless req_items.kind_of?(Array)

    begin
      updated_request = current_user_by_auth.remove_specified_subrequests(@request, req_items)
      render_request_with_sub_requests(updated_request, updated_request.user)
    rescue Exception => e
      render_client_error(e.message, 422) and return
    end
  end

  def update_req_items
    query_params = params.slice(:request_items)
    render_client_error("Invalid JSON format", 422) and return unless valid_json?(query_params[:request_items])
    req_items = JSON.parse(query_params[:request_items])
    render_client_error("JSON format must be array", 422) and return unless req_items.kind_of?(Array)

    begin
      updated_request = current_user_by_auth.update_specified_subrequests(@request, req_items)
      render_request_with_sub_requests(updated_request, updated_request.user)
    rescue Exception => e
      render_client_error(e.message, 422) and return
    end
  end

  def return_req_items
    query_params = params.slice(:request_items)
    render_client_error("Invalid JSON format", 422) and return unless valid_json?(query_params[:request_items])
    req_items = JSON.parse(query_params[:request_items])
    render_client_error("JSON format must be array", 422) and return unless req_items.kind_of?(Array)

    begin
      updated_request = current_user_by_auth.return_specified_items(@request, req_items)
      render_request_with_sub_requests(updated_request, updated_request.user)
    rescue Exception => e
      render_client_error(e.message, 422) and return
    end
  end

  private
  def render_request_with_sub_requests(request, user)
    render :json => request.instance_eval {
        |req| {
          :user => user.email,
          :reason => req.reason,
          :status => req.status,
          :requested_for => User.find(req.user_id).username,
          :request_type => req.determine_request_type,
          :sub_requests => req.request_items.map {
              |req_item| {
                :item => Item.find(req_item.item_id).unique_name,
                :quantity_on_loan => req_item.quantity_loan,
                :quantity_disbursed => req_item.quantity_disburse,
                :quantity_returned => req_item.quantity_return,
                :subrequest_type => req_item.determine_subrequest_type
            }
          }
      }
    }, status: 200
  end

  private
  def render_multiple_requests(requests)
    render :json => requests.map {
        |req| {
          :id => req.id,
          :user => req.user.email,
          :reason => req.reason,
          :status => req.status,
          :response => req.response,
          :request_initiator => req.request_initiator,
          :request_type => req.determine_request_type,
          :sub_requests => req.request_items.map {
              |req_item| {
                :item => Item.find(req_item.item_id).unique_name,
                :quantity_on_loan => req_item.quantity_loan,
                :quantity_disbursed => req_item.quantity_disburse,
                :quantity_returned => req_item.quantity_return,
                :subrequest_type => req_item.determine_subrequest_type
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
  def render_422_if_request_not_outstanding!(request_id)
    req = Request.find(request_id)

    render json: { errors: 'Request is not outstanding' }, status: 422 unless
        req && req.outstanding?
  end

  private
    def request_params
      params.fetch(:request, {}).permit(:user_id, :reason, :status, :request_type, :response, :email)
    end
end
