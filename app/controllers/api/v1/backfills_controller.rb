class Api::V1::BackfillsController < BaseController

  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: []
  before_action :render_404_if_request_unknown, only: []
  # before_action :set_request, only: [:show, :decision, :update_general, :create_req_items, :destroy_req_items, :update_req_items, :return_req_items]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :backfills, 'Backfills'

  swagger_api :create do
    summary "Creates a Backfill"
    notes "
    Example for backfill:
    [
      {
        \"item_name\": \"item1\",
        \"quantity_loan\": 15,
        \"quantity_disburse\": 13
      },
      {
        \"item_name\": \"item2\",
        \"quantity_loan\": 0,
        \"quantity_disburse\": 12
      }
    ]
    "
    param :form, 'request[reason]', :string, :optional, "Reason for request"
    param :form, 'request[email]', :string, :required, "Email address of user to request for"
    param :query, :request_items, :string, :required, 'Example --> [{"item_name": "item1", "quantity_loan": 15, "quantity_disburse": 13}, ...]'
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

  # private
  # def render_multiple_backfills(backfill_requestItems)
  #   render :json => backfill_requestItems.where(:name => params[:name]), status: 200
  # end

end

