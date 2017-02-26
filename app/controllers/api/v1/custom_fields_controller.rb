class Api::V1::CustomFieldsController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_admin_privilege!, only: [:create, :update_name, :update_privacy, :update_type, :clear_field_content, :destroy]
  before_action :render_404_if_custom_field_unknown, only: [:update_name, :update_privacy, :update_type, :destroy, :clear_field_content, :show]
  before_action :set_custom_field, only: [:update_name, :update_privacy, :update_type, :destroy, :clear_field_content, :show]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :custom_fields, 'CustomFields'

  swagger_api :index do
    summary 'Returns specified CustomFields'
    notes 'Specify query params'
    param :query, :field_name, :string, :optional, "Field Name"
    param :query, :private_indicator, :boolean, :optional, "Private?"
    param_list :query, :field_type, :string, :optional,
               "Field Type; must be short_text_type/long_text_type/integer_type/float_type",
               [:short_text_type, :long_text_type, :integer_type, :float_type]
    response :unauthorized
    response :unprocessable_entity
    response :ok
  end

  def index
    filter_params = params.slice(:field_name, :private_indicator, :field_type)

    render_client_error("Inputted Field Type is not short_text_type/long_text_type/integer_type/float_type!", 422) and
        return unless enum_processable?(filter_params[:field_type], CustomField::FIELD_TYPE_OPTIONS)

    filtered_custom_fields = CustomField.filter(filter_params)

    if current_user_by_auth.privilege_student?
      filtered_custom_fields = filtered_custom_fields.public_send(:private_indicator, false)
    end

    render :json => filtered_custom_fields, status: 200
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