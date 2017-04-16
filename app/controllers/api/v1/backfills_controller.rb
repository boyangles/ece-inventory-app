class Api::V1::BackfillsController < BaseController

  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_sole_user!, only: [:create]
  before_action :auth_by_manager_privilege!, only: []
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
    # notes "
    # Example for backfill:
    # [
    #   {
    #     \"item_name\": \"item1\",
    #     \"quantity_loan\": 15,
    #     \"quantity_disburse\": 13
    #   },
    #   {
    #     \"item_name\": \"item2\",
    #     \"quantity_loan\": 0,
    #     \"quantity_disburse\": 12
    #   }
    # ]
    # "
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
    locked_status = backfill_status_locked?(@request_item)
    100.times do |i|
      puts "Fuck me in the ass"
      puts locked_status
    end
    if locked_status
      render json: { errors: 'Request Item status is now locked' } and return
    end
    begin
      @request_item.update_attributes!(bf_status: request_item_params[:bf_status])
      render :json => @request_item
      UserMailer.backfill_approved_email(@request_item,old_status).deliver_now
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

  private

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

  # def render_multiple_backfills(backfill_requestItems)
  #   render :json => backfill_requestItems.where(:name => params[:name]), status: 200
  # end

end

