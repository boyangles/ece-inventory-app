class Api::V1::StocksController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:update_field_entry]
  before_action :auth_by_admin_privilege!, only: [:update_serial_tag]
  before_action :render_404_if_stock_unknown, only: [:show, :update_serial_tag, :update_field_entry]
  before_action :set_stock, only: [:show, :update_serial_tag, :update_field_entry]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:update_serial_tag, :update_field_entry].each do |api_action|
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
    param :query, :item_id_search, :integer, :optional, "Search by Item ID"
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

  swagger_api :update_field_entry do
    summary 'Updates corresponding Asset Custom Field with content'
    notes ""
    param :path, :id, :integer, :required, "Asset ID"
    param :query, :asset_cf_name, :string, :required, "Asset Custom Field to be updated"
    param :query, :asset_cf_content, :string, :required, "Field Content"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  def update_field_entry
    filter_params = params.slice(:asset_cf_name, :asset_cf_content)
    render_client_error("Inputted custom field doesn't exist!", 422) and
        return unless CustomField.exists?(field_name: filter_params[:asset_cf_name])

    custom_field = CustomField.find_by(field_name: filter_params[:asset_cf_name])
    scf_column = CustomField.find_icf_field_column(custom_field.id)

    render_client_error("Custom Field must be per-asset custom field", 422) and
        return unless custom_field.is_stock

    scf = StockCustomField.find_by(stock_id: @stock.id, custom_field_id: custom_field.id)

    if !scf.blank? && scf.update_attributes({ scf_column => filter_params[:asset_cf_content] })
      render_single_stock_with_stock_custom_fields(@stock)
    else
      render_client_error(scf.errors, 422)
    end
  end

  def update_serial_tag
    begin
      @stock.update_attributes!(serial_tag: stock_params[:serial_tag])
      render_single_stock_with_stock_custom_fields(@stock)
    rescue Exception => e
      render_client_error(e, 422)
    end
  end

  def show
    begin
      render_single_stock_with_stock_custom_fields(@stock)
    rescue => e
      render_client_error(e.message, 422)
    end
  end

  def index
    begin
      filter_hash = {}
      filter_hash[:serial_tag] = params[:serial_tag_search] unless params[:serial_tag_search].blank?
      filter_hash[:item_id] = params[:item_id_search] unless params[:item_id_search].blank?

      output_stocks = Stock.filter(filter_hash)
      render_multiple_stocks(output_stocks)
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

  def render_single_stock_with_stock_custom_fields(input_stock)
    render :json => input_stock.instance_eval {
        |stock| {
          stock_id: stock.id,
          serial_tag: stock.serial_tag,
          item_id: stock.item_id,
          item_name: stock.item.unique_name,
          available: stock.available,
          asset_custom_fields: stock.item.custom_fields.where(is_stock: true).map {
              |cf| {
                key: cf.field_name,
                value: StockCustomField.field_content(stock.id, cf.id),
                type: cf.field_type
            }
          }
      }
    }, status: 200
  end

  def render_multiple_stocks(stocks)
    render :json => stocks.map {
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