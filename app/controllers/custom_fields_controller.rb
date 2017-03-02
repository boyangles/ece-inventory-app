class CustomFieldsController < ApplicationController
  before_action :set_custom_field, only: [:destroy]

  def create
    if CustomField.create(custom_field_params)
      flash[:success] = "Custom Field created!"
    else
      flash[:danger] = "Check your inputs!"
    end
    redirect_to items_path
  end

  def destroy
    @custom_field.destroy!
    flash[:success] = "Custom Field deleted!"
    redirect_to items_path
  end

  private
  def set_custom_field
    @custom_field = CustomField.find(params[:id])
  end

  def custom_field_params
    params.fetch(:custom_field, {}).permit(:field_name, :private_indicator, :field_type)
  end
end