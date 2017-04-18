class StocksController < ApplicationController

  before_action :set_stock, only: [:show, :edit, :update, :destroy]
  before_action :set_item, only: [:show, :edit, :update, :destroy, :create]
  before_action :check_manager_or_admin, only: [:index, :show, :edit, :create, :update]
  before_action :check_admin_user, only: [:destroy]
  before_action :verify_item_is_stocked

  def index

    @item = Item.find(params[:item_id])
    filter_params = params.slice(:available)
    @stocks = Stock.where(item_id: @item.id).filter(filter_params).filter_by_search(params[:search]).paginate(page: params[:page], per_page: 10)
  end

  def show
    @item_custom_fields = ItemCustomField.where(item_id: @item.id)
    @stock_custom_fields = StockCustomField.where(stock_id: @stock.id)
    @request_item_stock = RequestItemStock.find_by(stock_id: @stock.id, status: 'loan')
  end

  def new
    @stock = Stock.new
  end

  def create
    @stock = @item.stocks.new
    if @stock.save
      respond_to do |format|
        format.html { redirect_to item_stocks_path(@item) }
        format.js
      end
    else
      flash.now[:danger] = "Cannot create stock"
      render :new
    end

  end

  def edit
    @stock_custom_fields = StockCustomField.where(stock_id: @stock.id)
  end

  def update
    begin
      current_user.update_stock_attributes(@stock, stock_params)
      flash[:success] = "Stock updated"
      redirect_to item_stock_path(@item, @stock)
    rescue Exception => e
      flash.now[:danger] = e.message
      @stock.reload
      render :edit
    end
  end

  def destroy

    @stock = @item.stocks.find(params[:id])
    begin
      @item.delete_stock(@stock)
    rescue Exception => e
      flash[:danger] = e.message
      redirect_to item_stocks_path @item
    end

    respond_to do |format|
      flash[:success] = "Asset Deleted"
      format.html { redirect_to item_stocks_path(@item) }
      format.js
    end

  end

  private

  def stock_params
    params.fetch(:stock, {}).permit(:serial_tag,
                                    :available,
                                    :item_id,
                                    stock_custom_fields_attributes: [:short_text_content,
                                                                    :long_text_content,
                                                                    :integer_content,
                                                                    :float_content,
                                                                    :stock_id, :custom_field_id, :id])
    # params.require(:stock).permit(:item_id, :available, :serial_tag)
  end

  def set_stock
    @stock = Stock.find(params[:id])
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  def verify_item_is_stocked
    set_item
    unless @item.has_stocks
      flash[:danger] = "Item has not been converted to assets"
      redirect_to item_path @item
    end
  end
end

