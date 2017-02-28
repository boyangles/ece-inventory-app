class Api::V1::ItemsController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:create, :create_tag_associations, :destroy_tag_associations, :update_general]
  before_action :auth_by_admin_privilege!, only: [:destroy, :fix_quantity, :clear_field_entries, :update_field_entry]
  before_action :render_404_if_item_unknown, only: [:destroy, :create_tag_associations, :destroy_tag_associations, :show, :update_general, :fix_quantity, :clear_field_entries, :update_field_entry]
  before_action :set_item, only: [:destroy, :create_tag_associations, :destroy_tag_associations, :show, :update_general, :fix_quantity, :clear_field_entries, :update_field_entry]


  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:create_tag_associations, :destroy_tag_associations, :update_general, :fix_quantity, :clear_field_entries, :update_field_entry].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :items, 'Items'

  swagger_api :index do
    summary 'Returns all or specified Items'
    notes 'Search items'
    param :query, :search, :string, :optional, "Item Fuzzy Search"
    param :query, :model_search, :string, :optional, "Search by Model Number"
    param :query, :required_tag_names, :string, :optional, "Comma Deliminated list of Required Tag Names"
    param :query, :excluded_tag_names, :string, :optional, "Comma Deliminated list of Excluded Tag Names"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :show do
    summary 'Fetches a single item'
    notes 'Shows tag info as well as request info'
    param :path, :id, :integer, :required, "Item ID"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :create do
    summary "Create an Item"
    param :form, 'item[unique_name]', :string, :required, "Item Name"
    param :form, 'item[quantity]', :integer, :required, "Item Quantity"
    param :form, 'item[description]', :string, :required, "Item Description"
    param :form, 'item[model_number]', :string, :optional, "Optionality"
    response :unauthorized
    response :created
    response :unprocessable_entity
  end

  swagger_api :destroy do
    summary "Deletes an item"
    param :path, :id, :integer, :required, "Item ID"
    response :unauthorized
    response :no_content
    response :not_found
  end

  swagger_api :create_tag_associations do
    summary "Associates tag(s) with an item"
    param :path, :id, :integer, :required, "Item ID"
    param :query, :tag_names, :string, :optional, "Comma Deliminated list of Tag Names to be Associated"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  swagger_api :destroy_tag_associations do
    summary "Removes associations of tag(s) with an item"
    param :path, :id, :integer, :required, "Item ID"
    param :query, :tag_names, :string, :optional, "Comma Deliminated list of Tag Names to be Removed"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  swagger_api :update_general do
    summary "Updates general attributes (non-quantity) of an item"
    param :path, :id, :integer, :required, "Item ID"
    param :form, 'item[unique_name]', :string, :optional, "Item Name"
    param :form, 'item[description]', :string, :optional, "Item Description"
    param :form, 'item[model_number]', :string, :optional, "Model Number"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  swagger_api :fix_quantity do
    summary "Administrator Item Quantity fixes"
    param :path, :id, :integer, :required, "Item ID"
    param :form, 'item[quantity]', :integer, :required, "Updated Quantity"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  swagger_api :clear_field_entries do
    summary "Clears specified Custom Fields for Item"
    notes 'No custom field names means clearing all field entries'
    param :path, :id, :integer, :required, "Item ID"
    param :query, :custom_field_names, :string, :optional, "Comma Deliminated list of Custom Fields to be cleared"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  swagger_api :update_field_entry do
    summary "Updates corresponding Custom Field with content"
    param :path, :id, :integer, :required, "Item ID"
    param :query, :custom_field_name, :string, :required, "Custom Fields to be updated"
    param :query, :custom_field_content, :string, :required, "Field Content"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  def index
    filter_params = params.slice(:search, :model_search, :required_tag_names, :excluded_tag_names)
    required_tag_filters = (filter_params[:required_tag_names].blank?) ?
        [] : filter_params[:required_tag_names].split(",").map(&:strip)
    excluded_tag_filters = (filter_params[:excluded_tag_names].blank?) ?
        [] : filter_params[:excluded_tag_names].split(",").map(&:strip)

    render_client_error("Inputted 'Required Tags' has a tag that doesn't exist", 422) and
        return unless all_tag_names_exist?(required_tag_filters)
    render_client_error("Inputted 'Excluded Tags' has a tag that doesn't exist", 422) and
        return unless all_tag_names_exist?(excluded_tag_filters)

    items_req = Item.tagged_with_all(required_tag_filters).select("id")
    items_exc = Item.tagged_with_none(excluded_tag_filters).select("id")
    items_req_and_exc = Item.where(:id => items_req & items_exc)

    items = items_req_and_exc.
        filter_by_search(filter_params[:search]).
        filter_by_model_search(filter_params[:model_search]).
        order('unique_name ASC')

    render :json => items.map {
      |item| {
          :name => item.unique_name,
          :quantity => item.quantity,
          :description => item.description,
          :model_number => item.model_number,
          :tags => item.tags
      }
    }, status: 200
  end

  def show
    render_item_instance_with_tags_and_requests_and_custom_fields(@item)
  end

  def create
    item = Item.new(item_params)

    if item.save
      render :json => item, status: 200
    else
      render_client_error(item.errors, 422)
    end
  end

  def destroy
    @item.destroy
    head 204
  end

  def create_tag_associations
    filter_params = params.slice(:tag_names)
    tag_array = (filter_params[:tag_names].blank?) ?
        [] : filter_params[:tag_names].split(",").map(&:strip)

    render_client_error("Inputted 'Tags' has a tag that doesn't exist", 422) and
        return unless all_tag_names_exist?(tag_array)

    tag_array.each do |tag_name|
      tag = Tag.find_by(name: tag_name)
      ItemTag.create(tag_id: tag.id, item_id: @item.id) unless
          ItemTag.exists?(tag_id: tag.id, item_id: @item.id)
    end

    render_item_instance_with_tags(@item)
  end

  def destroy_tag_associations
    filter_params = params.slice(:tag_names)
    tag_array = (filter_params[:tag_names].blank?) ?
        [] : filter_params[:tag_names].split(",").map(&:strip)

    tag_array.each do |tag_name|
      tag = Tag.find_by(name: tag_name)
      if !tag.blank? && ItemTag.exists?(tag_id: tag.id, item_id: @item.id)
        ItemTag.find_by(tag_id: tag.id, item_id: @item.id).destroy
      end
    end

    render_item_instance_with_tags(@item)
  end

  def update_general
    general_params = item_params.slice(:unique_name, :description, :model_number)
    if @item.update(general_params)
      render_item_instance_with_tags_and_requests_and_custom_fields(@item)
    else
      render_client_error(@item.errors, 422)
    end
  end

  def fix_quantity
    quantity_params = item_params.slice(:quantity)
    if @item.update(quantity_params)
      render_item_instance_with_tags_and_requests_and_custom_fields(@item)
    else
      render_client_error(@item.errors, 422)
    end
  end

  def clear_field_entries
    filter_params = params.slice(:custom_field_names)
    custom_field_name_array = (filter_params[:custom_field_names].blank?) ?
        [] : filter_params[:custom_field_names].split(",").map(&:strip)

    render_client_error("Inputted 'Custom Fields' has a custom field that doesn't exist", 422) and
        return unless all_custom_field_names_exist?(custom_field_name_array)

    custom_field_name_array = CustomField.pluck(:field_name) unless !custom_field_name_array.empty?

    custom_field_name_array.each do |custom_field_name|
      custom_field = CustomField.find_by(:field_name => custom_field_name)
      ItemCustomField.clear_field_content(@item.id, custom_field.id)
    end

    head 204
  end

  def update_field_entry
    filter_params = params.slice(:custom_field_name, :custom_field_content)
    render_client_error("Inputted custom field doesn't exist", 422) and
        return unless CustomField.exists?(:field_name => filter_params[:custom_field_name])

    custom_field = CustomField.find_by(:field_name => filter_params[:custom_field_name])
    icf_column = CustomField.find_icf_field_column(custom_field.id)

    icf = ItemCustomField.find_by(item_id: @item.id, custom_field_id: custom_field.id)

    if !icf.blank? && icf.update_attributes({ icf_column => filter_params[:custom_field_content] })
      head 204
    else
      render_client_error(icf.errors, 422)
    end
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end

  private
  def render_404_if_item_unknown
    render json: { errors: 'Item not found!' }, status: 404 unless
        Item.exists?(params[:id])
  end

  private
  def item_params
    params.fetch(:item, {}).permit(:unique_name, :quantity, :model_number, :description)
  end

  private
  def render_item_instance_with_tags(input_item)
    render :json => input_item.instance_eval {
        |item| {
          :name => item.unique_name,
          :quantity => item.quantity,
          :description => item.description,
          :model_number => item.model_number,
          :tags => item.tags
      }
    }, status: 200
  end

  def render_item_instance_with_tags_and_requests_and_custom_fields(input_item)
    render :json => input_item.instance_eval {
        |item| {
          :name => item.unique_name,
          :quantity => item.quantity,
          :description => item.description,
          :model_number => item.model_number,
          :tags => item.tags,
          :requests => item.requests.map {
              |req| {
                :request_id => req.id,
                :user_id => req.user_id,
                :status => req.status,
                :request_type => req.request_type
            }
          },
          :custom_fields => item.custom_fields.map {
              |cf| {
                :key => cf.field_name,
                :value => ItemCustomField.field_content(item.id, cf.id),
                :type => cf.field_type
          }
      }
      }
    }, status: 200
  end
end