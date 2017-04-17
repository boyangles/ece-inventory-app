class Api::V1::BackfillsController < BaseController

  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_sole_user!, only: [:create]
  before_action :auth_by_manager_privilege!, only: [:change_status, :create_comment]
  before_action :render_404_if_request_item_unknown, only: [:create, :create_comment, :change_status]
  before_action :set_request_item, only: [:create, :create_comment, :change_status]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:change_status, :create_comment].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :request_items, 'Backfills'

  swagger_api :create do
    summary "Creates a Backfill"

    notes '
    Creates a backfill for an item belonging to an approved request, that was previously in the loan state. If the
    request item is in any state besides "loan", it will not be eligible for a new backfill request. A successfully created backfill
    will carry a backfill status of "bf_request".
    '
    param :form, 'Attachment', :string, :optional, "Attachment"
    param :form, 'request_item_id', :string, :required, "Request Item ID"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :index do
    summary "Shows all backfills made for student (self for students)"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :change_status do
    summary "Changes the status of a backfill (manager privilege required)"

    notes '
    Changes the status of a backfill. Important: the backfill must be in either the "bf_requested" or "bf_in_transit" state to be eligible
    for a conversion to a new backfill status.
    For the new backfill status, you may answer with the following choices.

    i) bf_in_transit - after the manager approves the pdf, he should change the status to this option. The current status of the backfill status must be bf_requested.
    ii) bf_denied - reverts the items in the backfill to a "loan status". The current status of the backfill status must be bf_requested.
    iii) bf_satisfied - returns the items in the backfill to the available pool. The current status of the backfill status must be bf_in_transit.
    iv) bf_failed - reverts the items in the backfill to a "loan status". The current status of the backfill status must be bf_in_transit.
    '

    param :form, 'request_item[bf_status]', :string, :optional, "New backfill status"
    param :form, 'request_item_id', :string, :required, "Request Item ID"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :create_comment do
    summary "Creates a comment associated with a certain backfill"
    param :form, 'request_item_comment[comment]', :string, :optional, "New comment"
    param :form, 'request_item_id', :string, :required, "Request Item ID"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :view_comments do
    summary "View all commments associated with a certain backfill"
    param :form, 'request_item[id]', :string, :required, "Request Item ID"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  def create
    old_status = @request_item.bf_status

    attachment_path = params[:Attachment]


    10.times do |i|
      puts "THe request item is #{@request_item}"
      puts attachment_path
    end

    render_client_error("The loan must be belong to you to initiate backfill", 422) and
        return unless loan_belongs_to_user?(@request_item)

    render_client_error("This loan is not eligible for a new backfill because it is in the #{@request_item.bf_status} state.", 422) and
        return unless old_status == "loan"

    #Somewhere, the request needs to be in loan state?

    # Need to instantiate an attachment!
    begin
      @request_item.update_attributes!(bf_status: "bf_request")
      render :json => @request_item
      UserMailer.backfill_approved_email(@request_item,old_status).deliver_now
    rescue Exception => e
      #not sure about this
      render_client_error(e.message, 422) and return
    end
  end

  def change_status
    old_status = @request_item.bf_status

    ## SERIES OF ILLEGAL STATE TRANSITIONS

    if old_status == "loan"
      render_client_error("The backfill status of this item cannot be changed because a backfill request has not been made yet.", 422) and return
    end

    if backfill_status_locked?(@request_item)
      render_client_error("Request Item status cannot be changed because it is locked. The current status is #{@request_item.bf_status}", 422) and return
    end

    if old_status == request_item_params[:bf_status]
      render_client_error("No change to the status has been made. The state of requestID #{@request_item.id} is still #{old_status}", 422) and return
    end

    if old_status == 'bf_in_transit' && (request_item_params[:bf_status] == 'loan' || request_item_params[:bf_status] == 'bf_denied' || request_item_params[:bf_status] == 'bf_request')
      render_client_error("The transition between state #{old_status} to #{request_item_params[:bf_status]} is prohibited.", 422) and return
    end

    begin
      if request_item_params[:bf_status] == "bf_satisfied"
        return_item(@request_item)
      else
        @request_item.update_attributes!(bf_status: request_item_params[:bf_status])
        render :json => @request_item
        UserMailer.backfill_approved_email(@request_item,old_status).deliver_now
      end
    rescue Exception => e
      render_client_error(e.message, 422) and return
    end
  end


  def index
    waiting = RequestItem.where(bf_status: "bf_request").select(:id)
    in_transit = RequestItem.where(bf_status: "bf_in_transit").select(:id)
    satisfied = RequestItem.where(bf_status: "bf_satisfied").select(:id)

    backfills_active = RequestItem.where(id: waiting | in_transit | satisfied)

    100.times do |i|
      puts backfills_active
    end

    if !is_manager_or_admin?
      backfills_active = backfills_active.where(request_id: Request.where(user_id: current_user.id).select(:id))
    end
    render :json => backfills_active
  end


  ## Need to edit this method, but basically its used to create a comment for a request_id
  def create_comment
    ## METHOD BELOW STOLEN FROM OTHER CONTROLLER - EDIT LATER

    # puts "loan belongs to user is #{loan_belongs_to_user?(@request_item)}"
    # puts "auth by manager privilege is #{auth_by_manager_privilege!}"

    # render_client_error("You may not comment on a backfill that is not yours#{@request_item.bf_status}", 422) and
    #     return unless (loan_belongs_to_user?(@request_item) || current_user_by_auth.privilege_manager? || current_user_by_auth.privilege_admin?)

    request_item_comment = RequestItemComment.new(request_item_comment_params)
    # puts "Comment Begins here ------------------"
    # puts request_item_comment_params[:comment]
    # 100.times do |i|
    #   puts "shit"
    #   puts current_user_by_auth.username
    #   puts request_item_comment.comment
    # end
    request_item_comment.user_id = current_user_by_auth.id
    request_item_comment.request_item_id = params[:request_item_id]
    request_item_comment.save!
    begin
      render json: request_item_comment
    rescue Exception => e
    #not sure about this
      render json: { errors: 'Your comment was not saved' }, status: 422
    end
  end


  def view_comments

  end


  def return_item(requestItem)

    reqQuant = requestItem.quantity_loan

    requestItem.curr_user = current_user
      if Item.find(requestItem.item_id).has_stocks
        current_user_by_auth.return_subrequest(requestItem, params[:serial_tags_loan_return], request_item_params[:bf_status])
      else
        current_user_by_auth.return_subrequest(requestItem, requestItem.quantity_loan.to_f, request_item_params[:bf_status])
      end
      render json: requestItem
      UserMailer.loan_return_email(requestItem,reqQuant).deliver_now
  end

  private

  def loan_belongs_to_user?(request_item)

    100.times do |i|
      puts "The request_item user is #{request_item.request.user.username}"
      puts "The current usre by auth is #{current_user_by_auth.username}"
    end

    if request_item.request.user.username == current_user_by_auth.username
        return true
    end
    return false
  end

  def backfill_status_locked?(request_item)
    100.times do |i|
      puts "the status of this request item is "
      puts request_item.bf_status
    end
    return request_item.bf_status == "bf_denied" || request_item.bf_status == "bf_satisfied" || request_item.bf_status == "bf_failed"
  end

  def render_404_if_request_item_unknown
    render json: { errors: 'Request Item not found!' }, status: 404 unless
        RequestItem.exists?(params[:request_item_id])
  end

  def set_request_item
    @request_item = RequestItem.find(params[:request_item_id])
  end

  def request_item_comment_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:request_item_comment, {}).permit(:comment)
  end

  def request_item_params
    params.fetch(:request_item, {}).permit(:bf_status)
  end

end

