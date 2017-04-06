class RequestItemStocksController < ApplicationController

  before_action :set_request_item_stock, only: [:show]

  def show

  end

  def new

  end

  def create


  end



  private

    def set_request_item_stock
      @request_item_stock = RequestItemStock.find(params[:id])
    end

  def request_item_stock_params
    params.require(:request_item_stock).permit(:request_item_id, :stock_id, :status)
  end
end
