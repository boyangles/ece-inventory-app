class Api::V1::ItemsController < ApplicationController
  respond_to :json

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
    params.fetch(:item, {}).permit(:unique_name, :quantity, :model_number, :description)
  end
end