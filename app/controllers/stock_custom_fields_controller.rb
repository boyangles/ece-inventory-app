class StockCustomFieldsController < ApplicationController

  before_action :set_stock_custom_field, only: [:update]

  def update
    respond_to do |format|
      if @stock_custom_field.update(stock_custom_field_params)
        format.html { redirect_to @stock_custom_field.stock, notice: 'Custom Field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to @stock_custom_field.stock, alert: 'Custom Field could not be modified' }
        format.json { render json: @stock_custom_field.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_stock_custom_field
    @stock_custom_field = StockCustomField.find(params[:id])
  end

  def stock_custom_field_params
    params.fetch(:stock_custom_field, {}).permit(:short_text_content,
                                                :long_text_content,
                                                :integer_content,
                                                :float_content)
  end
end
