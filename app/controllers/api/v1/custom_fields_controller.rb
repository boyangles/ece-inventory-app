class Api::V1::CustomFieldsController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_admin_privilege!, only: [:create, :update_name, :update_privacy, :update_type, :clear_field_content, :destroy]
  before_action :render_404_if_custom_field_unknown, only: [:update_name, :update_privacy, :update_type, :destroy, :clear_field_content, :show]
  before_action :set_custom_field, only: [:update_name, :update_privacy, :update_type, :destroy, :clear_field_content, :show]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :custom_fields, 'CustomFields'

  def index

  end

  def show

  end

  def create

  end

  def destroy

  end

  def update_name

  end

  def update_privacy

  end

  def update_type

  end

  def clear_field_content

  end

  private
  def set_custom_field
    @custom_field = CustomField.find(params[:id])
  end

  private
  def render_404_if_custom_field_unknown
    render json: { errors: 'Custom Field not found!' }, status: 404 unless
        CustomField.exists?(params[:id])
  end

  private
  def custom_field_params
    params.fetch(:custom_field, {}).permit(:field_name, :private_indicator, :field_type)
  end
end