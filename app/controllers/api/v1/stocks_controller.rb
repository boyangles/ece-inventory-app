class Api::V1::StocksController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:update_serial_tag]
  before_action :auth_by_admin_privilege!, only: []
  before_action :render_404_if_stock_unknown, only: [:show, :update_serial_tag]
  before_action :set_stock, only: [:show, :update_serial_tag]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:update_serial_tag].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :stocks, 'Stocks'

  swagger_api :index do
    summary 'Shows all Assets'
    notes ""
    param :query, :serial_tag_search, :string, :optional, "Search by Serial Tag"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :show do
    summary 'Shows a single Asset'
    notes ""
    param :path, :id, :integer, :required, "Asset ID"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :update_serial_tag do
    summary 'Updates the serial tag for an existing asset'
    notes ""
    param :path, :id, :integer, :required, "Asset_ID"
    param :form, 'stock[serial_tag]', :string, :required, "New Serial Tag"
    response :ok
    response :unauthorized
    response :not_found
  end

  def update_serial_tag
    begin
      @stock.update_attributes!(serial_tag: stock_params[:serial_tag])
      render_single_stock(@stock)
    rescue Exception => e
      render_client_error(e, 422)
    end
  end

  def show
    begin
      render_single_stock(@stock)
    rescue => e
      render_client_error(e.message, 422)
    end
  end

  def index
    begin
      output_stocks = (params[:serial_tag_search].blank?) ? Stock.all : Stock.filter({serial_tag: params[:serial_tag_search]})
      render :json => output_stocks.map {
          |stock| {
            item_id: stock.item_id,
            item_name: stock.item.unique_name,
            available: stock.available,
            serial_tag: stock.serial_tag
        }
      }, status: 200
    rescue Exception => e
      render_client_error(e.message, 422)
    end
  end

  ## Private Methods
  private
  def render_404_if_stock_unknown
    render json: { errors: 'Stock not found!' }, status: 404 unless
        Stock.exists?(params[:id])
  end

  def set_stock
    @stock = Stock.find(params[:id])
  end

  def stock_params
    params.fetch(:stock, {}).permit(:item_id, :available, :serial_tag)
  end

  def render_single_stock(input_stock)
    render :json => input_stock.instance_eval {
        |stock| {
          stock_id: stock.id,
          serial_tag: stock.serial_tag,
          item_id: stock.item_id,
          item_name: stock.item.unique_name,
          available: stock.available
      }
    }, status: 200
  end
end