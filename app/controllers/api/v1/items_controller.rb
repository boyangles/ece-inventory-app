class Api::V1::ItemsController < BaseController
  respond_to :json

  before_action :authenticate_with_token!
  before_action :auth_by_manager_privilege!, only: [:new, :create, :edit, :update]
  before_action :auth_by_admin_privilege!, only: [:destroy]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  swagger_controller :items, 'Items'

  # authentication_actions.each do |api_action|
  #   swagger_api api_action do
  #     param :header, :Authorization, :required, "Authorization Token"
  #   end
  # end

  swagger_api :index do
    summary 'Returns all items'
    notes 'These are some notes for everybody!'
    param :query, :page, :integer, :optional, "Page number"
    param :path, :nested_id, :integer, :optional, "Team Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :show do
    summary "Fetches a single item"
    param :path, :id, :integer, :required, "Item Id"
    response :ok, "Success", :item
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new Item"
    param :form, :unique_name, :string, :required, "Unique Name"
    param :form, :quantity, :number, :required, "Quantity"
    param :form, :description, :string, :required, "Description"
    param :form, :model_number, :string, :required, "Model Number"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing Item"
    notes 'Must have ID to update'
    param :path, :id, :integer, :required, "Item Id"
    param :form, :unique_name, :string, :required, "Unique Name"
    param :form, :quantity, :number, :required, "Quantity"
    param :form, :description, :string, :required, "Description"
    param :form, :model_number, :string, :required, "Model Number"
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes an existing item"
    param :path, :id, :integer, :required, "Item Id"
    response :unauthorized
    response :not_found
  end

  def index
    respond_with Item.all
  end

  def show
    respond_with Item.find(params[:id])
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: item, status: 201, location: [:api, item]
    else
      render json: { errors: item.errors }, status: 422
    end
  end

  def update
    item = Item.find(params[:id])

    if item.update(item_params)
      render json: item, status: 200, location: [:api, item]
    else
      render json: { errors: item.errors }, status: 422
    end
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy
    head 204
  end

  private
  def item_params
    params.permit(:unique_name, :quantity, :model_number, :description)
  end
end