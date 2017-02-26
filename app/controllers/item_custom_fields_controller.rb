class ItemCustomFieldsController < ApplicationController
  before_action :set_item_custom_field, only: [:update]

  def update
    respond_to do |format|
      if @item_custom_field.update(item_custom_field_params)
        format.html { redirect_to @item_custom_field.item, notice: 'Custom Field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to @item_custom_field.item, alert: 'Custom Field could not be modified' }
        format.json { render json: @item_custom_field.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_item_custom_field
    @item_custom_field = ItemCustomField.find(params[:id])
  end

  def item_custom_field_params
    params.fetch(:item_custom_field, {}).permit(:short_text_content,
                                                :long_text_content,
                                                :integer_content,
                                                :float_content)
  end
end