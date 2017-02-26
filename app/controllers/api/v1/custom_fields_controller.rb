class Api::V1::CustomFieldsController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_admin_privilege!, only: [:create, :update_name, :update_privacy, :update_type, :destroy]
  before_action :render_404_if_custom_field_unknown, only: [:update_name, :update_privacy, :update_type, :destroy, :show]
  before_action :set_custom_field, only: [:update_name, :update_privacy, :update_type, :destroy, :show]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:update_name, :update_privacy, :update_type].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

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

  swagger_api :show do
    summary "Fetches a specific custom field"
    param :path, :id, :integer, :required, "Custom Field ID"
    response :ok, "Success", :custom_field
    response :unauthorized
    response :not_found
  end

  swagger_api :create do
    summary "Creates a Custom Field"
    param :form, 'custom_field[field_name]', :string, :required, "Field Name"
    param :form, 'custom_field[private_indicator]', :boolean, :required, "Private?"
    param_list :form, 'custom_field[field_type]', :string, :required, "Field Type; must be short_text_type/long_text_type/integer_type/float_type",
               ["short_text_type", "long_text_type", "integer_type", "float_type"]
    response :created
    response :unauthorized
  end

  swagger_api :destroy do
    summary "Deletes a Custom Field"
    param :path, :id, :integer, :required, "Custom Field ID"
    response :unauthorized
    response :no_content
    response :not_found
  end

  swagger_api :update_name do
    summary "Updates the name of a Custom Field"
    param :path, :id, :integer, :required, "Custom Field ID"
    param :form, 'custom_field[field_name]', :string, :required, "Updated Field Name"
    response :unauthorized
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :update_privacy do
    summary  "Updates the privacy setting of a Custom Field"
    param :path, :id, :integer, :required, "Custom Field ID"
    param :form, 'custom_field[private_indicator]', :boolean, :required, "Updated is Private?"
    response :unauthorized
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :update_type do
    summary "Updates the field type of a Custom Field"
    param :path, :id, :integer, :required, "Custom Field ID"
    param_list :form, 'custom_field[field_type]', :string, :required, "Field Type; must be short_text_type/long_text_type/integer_type/float_type",
               ["short_text_type", "long_text_type", "integer_type", "float_type"]
    response :unauthorized
    response :ok
    response :unprocessable_entity
    response :not_found
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
    if current_user_by_auth.privilege_student? && @custom_field.private_indicator
      render_client_error("Students may not view private fields", 401)
    else
      render :json => @custom_field, status: 200
    end
  end

  def create
    render_client_error("Inputted Field Type is not short_text_type/long_text_type/integer_type/float_type!", 422) and
        return unless enum_processable?(custom_field_params[:field_type], CustomField::FIELD_TYPE_OPTIONS)

    custom_field = CustomField.new(custom_field_params)
    if custom_field.save
      render :json => custom_field, status: 201
    else
      render_client_error(custom_field.errors, 422)
    end
  end

  def destroy
    @custom_field.destroy
    head 204
  end

  def update_name
    field_name_params = custom_field_params.slice(:field_name)
    if @custom_field.update(field_name_params)
      render :json => @custom_field, status: 200
    else
      render :json => { errors: @custom_field.errors }, status: 422
    end
  end

  def update_privacy
    private_indicator_params = custom_field_params.slice(:private_indicator)
    if @custom_field.update(private_indicator_params)
      render :json => @custom_field, status: 200
    else
      render :json => { errors: @custom_field.errors }, status: 422
    end
  end

  def update_type
    field_type_params = custom_field_params.slice(:field_type)
    render_client_error("Inputted Field Type is not short_text_type/long_text_type/integer_type/float_type!", 422) and
        return unless enum_processable?(field_type_params[:field_type], CustomField::FIELD_TYPE_OPTIONS)

    if @custom_field.update(field_type_params)
      render :json => @custom_field, status: 200
    else
      render :json => { errors: @custom_field.errors }, status: 422
    end
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