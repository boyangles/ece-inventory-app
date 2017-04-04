class StocksController < ApplicationController

  before_action :set_stock, only: [:show, :edit, :update, :destroy]
  before_action :set_item, only: [:destroy, :create]

  def index
    @item = Item.find(params[:item_id])
    @stocks = Stock.where(item_id: @item.id).paginate(page: params[:page], per_page: 10)
  end

  def show

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

  end

  def update

  end

  def destroy

    @stock = @item.stocks.find(params[:id])
    @stock.delete
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end


  end

  private

  def stock_params
    params.require(:stock).permit(:item_id, :available, :serial_tag)
  end

  def set_stock
    @stock = Stock.find(params[:id])
  end

  def set_item
    @item = Item.find(params[:item_id])
  end
end

