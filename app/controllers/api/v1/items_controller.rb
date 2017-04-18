class Api::V1::ItemsController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:create, :create_tag_associations, :destroy_tag_associations, :update_general, :bulk_minimum_stock, :all_minimum_stock, :bulk_import, :convert_to_stocks, :convert_to_global]
  before_action :auth_by_admin_privilege!, only: [:destroy, :fix_quantity, :clear_field_entries, :update_field_entry, :create_stocks, :create_single_stock]
  before_action :render_404_if_item_unknown, only: [:destroy, :create_tag_associations, :destroy_tag_associations, :show, :update_general, :fix_quantity, :clear_field_entries, :update_field_entry, :self_outstanding_requests, :self_loans, :convert_to_stocks, :convert_to_global, :create_stocks, :create_single_stock, :backfill_requested, :backfill_transit]
  before_action :set_item, only: [:destroy, :create_tag_associations, :destroy_tag_associations, :show, :update_general, :fix_quantity, :clear_field_entries, :update_field_entry, :self_outstanding_requests, :self_loans, :convert_to_stocks, :convert_to_global, :create_stocks, :create_single_stock, :backfill_requested, :backfill_transit]



  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:create_tag_associations, :destroy_tag_associations, :update_general, :fix_quantity, :clear_field_entries, :update_field_entry, :bulk_import, :bulk_minimum_stock, :all_minimum_stock, :self_outstanding_requests, :self_loans, :convert_to_stocks, :convert_to_global, :create_stocks, :create_single_stock, :backfill_requested, :backfill_transit].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :items, 'Items'

  swagger_api :index do
    summary 'Returns all or specified Items'
    notes '
    Implements Item search.
    If no parameters are specified, then the API returns all available items.

    i) search -- represents a fuzzy search on an item
        Resis --- returns item named Resistor
    ii) model_search -- represents a strict search by model name
        P90XF --- returns item with model numebr P90XF exactly
    iii) required_tag_names -- search items that MUST include all the specified required tags
        ECE110, ECE250 --- returns only items who have BOTH of the specified tags
    iv) excluded_tag_names -- search items that MUST NOT include ANY of the specified excluded tags
        ECE110, ECE250 --- returns all items who have neither of the specified tags
    v) unstocked -- search items that have quantities that are BELOW the minimum stock.
        You must answer either true or false.
        Answer true to see all items that have quantity below minimum stock & satisfy the other constraints.
        Answer false to see all items satisfying the other constraints.
    '
    param :query, :search, :string, :optional, "Item Fuzzy Search"
    param :query, :model_search, :string, :optional, "Search by Model Number"
    param :query, :required_tag_names, :string, :optional, "Comma Deliminated list of Required Tag Names"
    param :query, :excluded_tag_names, :string, :optional, "Comma Deliminated list of Excluded Tag Names"
    param :query, :stocked, :string, :optional, "Include only items below Minimum Stock(true or false)"
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
    param :form, 'item[description]', :string, :optional, "Item Description"
    param :form, 'item[minimum_stock]', :integer, :optional, "Minimum Stock"
    param :form, 'item[model_number]', :string, :optional, "Optional Model Number"
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
    notes "
    tag_names input is a comma deliminated list of tag names to be associated.
    Example:
      ECE110, ECE230, ECE559
    "
    param :path, :id, :integer, :required, "Item ID"
    param :query, :tag_names, :string, :optional, "Comma Deliminated list of Tag Names to be Associated"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  swagger_api :destroy_tag_associations do
    summary "Removes associations of tag(s) with an item"
    notes "
    Deletes tags associated with an item (by item id). Can do one of two actions:
      i) Delete all tags associated with the item (if tag_names is empty)
      ii) Deletes only the specified tags listed by tag_names (if tag_names is not empty)
    Example for tag_names:
      ii) ECE110, ECE230, ECE559
    "
    param :path, :id, :integer, :required, "Item ID"
    param :query, :tag_names, :string, :optional, "Comma Deliminated list of Tag Names to be Removed"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  swagger_api :update_general do
    summary "Updates general attributes (non-quantity) of an item"
    notes "
    Updates general attributes associated with an item (item name, description, model number, and minimum stock).
    These updates are all optional. If none are filled out, then the item simply doesn't update.
    "
    param :path, :id, :integer, :required, "Item ID"
    param :form, 'item[unique_name]', :string, :optional, "Item Name"
    param :form, 'item[description]', :string, :optional, "Item Description"
    param :form, 'item[minimum_stock]', :integer, :optional, "Minimum Stock"
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

  swagger_api :bulk_minimum_stock do
    summary "Set minimum stock of many items at once. "
    notes "
    The format of the items should be in the form [\"x\", \"y\", \"z\", \"a\"], where 'x', 'y', 'z', and 'a' are integers that reference the item_id of the item that will be modified.
    All the items in the array will have their minimum quantity changed to the value of the updated minimum stock quantity
    "

    param :query, 'items', :string, :required, "Items to update"
    param :query, 'min_quantity', :integer, :required, "Updated minimum stock quantity"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end

  swagger_api :all_minimum_stock do
    summary "Set minimum stock of ALL items at once."
    param :query, 'min_quantity', :integer, :required, "Updated minimum stock quantity"
    response :ok
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end


  swagger_api :clear_field_entries do
    summary "Clears specified Custom Fields for Item"
    notes "
    Deletes custom fields associated with an item (by item id). Can do one of two actions:
      i) Clear all custom field entries associated with the item (if custom_field_names is empty)
      ii) Clears only the specified custom fields listed by custom_field_names (if custom_field_names is not empty)
    Example for custom_field_names:
      ii) location, restock_info
    "
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

  swagger_api :bulk_import do
    summary "Bulk Import Items"
    notes "
    Adds a general amount of items (including their tag associations and custom field associations).
    Look at BulkImportGuide.md for more details on the exact syntax in JSON format.

    Example:
      [{
        \"unique_name\": \"test_name_0\",
        \"quantity\": 153,
        \"model_number\": \"5x937s\",
        \"description\": \"Sample description 0\",
        \"tags\": [\"ECE110\", \"ECE350\", \"Outdated\"],
        \"custom_fields\": [
            {
              \"name\": \"price\",
              \"value\": 35
            }, {
              \"name\": \"location\",
              \"value\": \"CIEMAS\"
            }
          ]
        }, {
        \"unique_name\": \"test_name_1\",
        \"quantity\": 12,
        \"tags\": [],
        \"custom_fields\": []
      }]
    "
    param :query, :items_as_json, :string, :required, "Items as JSON"
    response :unauthorized
    response :created
    response :unprocessable_entity
  end

  swagger_api :self_outstanding_requests do
    summary "View own outstanding requests for specified item"
    notes "
    Finds all outstanding subrequests (and their associated requests) for a particular item that are related to the specified user.
    "
    param :path, :id, :integer, :required, "Item ID"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :self_loans do
    summary "View subrequest loans for a specific item"
    notes "
    Finds all loans (of subrequest type) and their associated requests for a particular item that are associated with current user.
    "
    param :path, :id, :integer, :required, "Item ID"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :convert_to_stocks do
    summary "Converts all the quantities for a particular item to assets"
    notes "
    Converts an item and all its associated quantities to be tracked as assets. Dependent on the following criteria
    - has_stocks for specified Item must be false
    "
    param :path, :id, :integer, :required, "Item ID"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :convert_to_global do
    summary "Converts all the associated assets for a particular item to quantity and quantity_on_loan"
    notes "
    Converts all stocks for an item to quantity. Equivalent to deleting these entries from the Stocks table. Dependent on the following criteria:
    - has_stocks is for specified Item must be true
    "
    param :path, :id, :integer, :required, "Item ID"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :create_stocks do
    summary "Creates stocks for a specified Item"
    notes ""
    param :path, :id, :integer, :required, "Item ID"
    param :query, :stock_quantity, :string, :required, "Quantity of stocks to create"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :create_single_stock do
    summary "Creates a single stock for a specified Item"
    notes ""
    param :path, :id, :integer, :required, "Item ID"
    param :query, :stock_serial_tag, :string, :required, "Serial Tag of stock to be created"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :backfill_requested do
    summary "View Item stack for request_items that have backfills requested"
    notes "
    For students, only view request_items that correspond to self that are backfilled requested.
    For managers/admins, view all request_items that are backfills requested.
    "
    param :path, :id, :integer, :required, "Item ID"
    response :ok
    response :unauthorized
    response :not_found
  end

  swagger_api :backfill_transit do
    summary "View Item stack for request_items that have backfills in transit"
    notes "
    For students, only view request_items that correspond to own request_items that are backfills.
    For managers/admins, view all request_items that are backfills in transit
    "
    param :path, :id, :integer, :required, "Item ID"
    response :ok
    response :unauthorized
    response :not_found
  end

  def backfill_requested
    begin
      request_items = (current_user_by_auth.privilege_student?) ?
          RequestItem.filter({item_id: @item.id, user_id: current_user_by_auth.id, bf_status: "bf_request"}) :
          RequestItem.filter({item_id: @item.id, bf_status: "bf_request"})

      render :json => request_items.map {
        |request_item| {
            request_item_id: request_item.id,
            request_id: request_item.request_id,
            item_name: request_item.item.unique_name,
            item_id: request_item.item.id,
            quantity_on_loan: request_item.quantity_loan,
            quantity_disbursed: request_item.quantity_disburse,
            quantity_returned: request_item.quantity_return
        }
      }, status: 200
    rescue Exception => e
      render_client_error(e.message, 422)
    end
  end

  def backfill_transit
    begin
      request_items = (current_user_by_auth.privilege_student?) ?
          RequestItem.filter({item_id: @item.id, user_id: current_user_by_auth.id, bf_status: "bf_in_transit"}) :
          RequestItem.filter({item_id: @item.id, bf_status: "bf_in_transit"})

      render :json => request_items.map {
          |request_item| {
            request_item_id: request_item.id,
            request_id: request_item.request_id,
            item_name: request_item.item.unique_name,
            item_id: request_item.item.id,
            quantity_on_loan: request_item.quantity_loan,
            quantity_disbursed: request_item.quantity_disburse,
            quantity_returned: request_item.quantity_return
        }
      }, status: 200
    rescue Exception => e
      render_client_error(e.message, 422)
    end
  end

  def create_single_stock
    begin
      stock = @item.create_stock!(params[:stock_serial_tag])
      render_single_stock(stock)
    rescue Exception => e
      render_client_error(e, 422)
    end
  end

  def create_stocks
    begin
      raise Exception.new('Inputted stock quantity must be greater than 0') if params[:stock_quantity].to_i <= 0
      Stock.create_stocks!(params[:stock_quantity].to_i, @item.id)
      render_multiple_stocks(@item.stocks)
    rescue Exception => e
      render_client_error(e, 422)
    end
  end

  def convert_to_global
    begin
      updated_item = @item.convert_to_global!
      render_item_instance_with_tags_and_requests_and_custom_fields(updated_item)
    rescue Exception => e
      render_client_error(e.message, 422)
    end
  end

  def convert_to_stocks
    begin
      created_stocks = @item.convert_to_stocks!
      render_multiple_stocks(created_stocks)
    rescue Exception => e
      render_client_error(e.message, 422)
    end
  end

  def self_outstanding_requests
    request_items = RequestItem.filter({:user_id => current_user_by_auth.id, :status => 'outstanding', :item_id => @item.id})
    render :json => request_items.map {
      |req_item| {
          :subrequest_id => req_item.id,
          :request_id => req_item.request_id,
          :item_id => req_item.item_id,
          :item => Item.find(req_item.item_id).unique_name,
          :quantity_on_loan => req_item.quantity_loan,
          :quantity_disbursed => req_item.quantity_disburse,
          :quantity_returned => req_item.quantity_return,
          :subrequest_type => RequestItem.find(req_item.id).determine_subrequest_type
      }
    }, status: 200
  end

  def self_loans
    request_items = RequestItem.filter({:user_id => current_user_by_auth.id, :item_id => @item.id, :status => 'approved'})
    request_items = request_items.filter({:request_type => 'loan'}).or(request_items.filter({:request_type => 'mixed'}))
    render :json => request_items.map {
        |req_item| {
          :subrequest_id => req_item.id,
          :request_id => req_item.request.id,
          :item_id => @item.id,
          :item => @item.unique_name,
          :due_date => req_item.due_date,
          :quantity_on_loan => req_item.quantity_loan,
          :quantity_disbursed => req_item.quantity_disburse,
          :quantity_returned => req_item.quantity_return,
          :subrequest_type => req_item.determine_subrequest_type
      }
    }, status: 200
  end

  def index
    filter_params = params.slice(:search, :model_search, :required_tag_names, :excluded_tag_names)
    required_tag_filters = (filter_params[:required_tag_names].blank?) ?
        [] : filter_params[:required_tag_names].split(",").map(&:strip)
    excluded_tag_filters = (filter_params[:excluded_tag_names].blank?) ?
        [] : filter_params[:excluded_tag_names].split(",").map(&:strip)

    stocked_response = params[:stocked]

    render_client_error("Inputted 'Required Tags' has a tag that doesn't exist", 422) and
        return unless all_tag_names_exist?(required_tag_filters)
    render_client_error("Inputted 'Excluded Tags' has a tag that doesn't exist", 422) and
        return unless all_tag_names_exist?(excluded_tag_filters)

    render_client_error("You must answer either true or false for the minimum stock filter", 422) and
        return unless stocked_filter_correct_reponses?(stocked_response)

    items_req = Item.tagged_with_all(required_tag_filters).select("id")
    items_exc = Item.tagged_with_none(excluded_tag_filters).select("id")
    items_unstocked = Item.all
    if stocked_response == "true"
      items_unstocked = Item.minimum_stock
    end

    items_req_and_exc_and_unstocked= Item.where(:id => items_req & items_exc & items_unstocked)

    items = items_req_and_exc_and_unstocked.
        filter_by_search(filter_params[:search]).
        filter_by_model_search(filter_params[:model_search]).
        order('unique_name ASC')

    render :json => items.map {
      |item| {
          :name => item.unique_name,
          :quantity => item.quantity,
          :description => item.description,
          :minimum_stock => item.minimum_stock,
          :model_number => item.model_number,
          :tags => item.tags
      }
    }, status: 200
  end

  def show
    render_item_instance_with_tags_and_requests_and_custom_fields(@item)
  end

  def create
    item = Item.new(item_params.merge({last_action: 'created'}))

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
    general_params = item_params.slice(:unique_name, :description, :model_number, :minimum_stock)
    if @item.update(general_params)
      render_item_instance_with_tags_and_requests_and_custom_fields(@item)
    else
      render_client_error(@item.errors, 422)
    end
  end

  def fix_quantity
    render_client_error("Cannot change quantity for item that is per-asset", 422) and return if @item.has_stocks

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

  def bulk_minimum_stock

    items = params[:items]
    min_quantity = params[:min_quantity]

    render_client_error("Invalid JSON format", 422) and return unless valid_json?(items)

    items_to_change = JSON.parse(items)
    render_client_error("JSON format must be array", 422) and return unless items_to_change.kind_of?(Array)

    items_to_change.each do |i|
      puts "This item is _"
      puts i
    end

    if update_min_stock_of_certain_items_using_id(items_to_change,min_quantity)

    else
      render_client_error(@item.errors, 422)
    end
  end

  def all_minimum_stock
    min_quantity = params[:min_quantity]
    if update_min_stock_of_certain_items(Item.all,min_quantity)

    else
      render_client_error(@item.errors, 422)
    end
    # render :json => items_to_change
  end

  ##DUplicated code!!

  def minimum_stock_email_changed_min_stock(min_before, min_after, item)
    10.times do |i|
      puts "The quantity before is:"
      puts min_before
      puts "The quantity after is:"
      puts min_after
      puts "The item is:"
      puts item.unique_name
    end
    if min_before >= item.quantity && min_after < item.quantity
      10.times do |i|
        puts "The conditinos except for threshold are met for email threshold to send!!!!"
      end
      if item.stock_threshold_tracked
        puts "THE EMAIL WILL DELIVER NOW"
        UserMailer.minimum_stock_min_stock_change(min_before, min_after, item).deliver_now
      end
    end
  end

  def minimum_stock_email(q_before, q_after, item)
    if q_before >= item.minimum_stock && q_after < item.minimum_stock
      10.times do |i|
        puts "The conditinos except for threshold are met for email threshold to send!!!!"
      end
      if item.stock_threshold_tracked
        puts "THE EMAIL WILL DELIVER NOW"
        UserMailer.minimum_stock_quantity_change(q_before, q_after, item).deliver_now
      end
    end
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

  def bulk_import
    bulk_import_params = params.slice(:items_as_json)

    begin
      Item.bulk_import(bulk_import_params[:items_as_json])
      head 200
    rescue Exception => e
      render_client_error(e.message, 422)
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
    params.fetch(:item, {}).permit(:unique_name, :quantity, :model_number, :description, :minimum_stock)
  end


  private
  def render_item_instance_with_tags(input_item)
    render :json => input_item.instance_eval {
        |item| {
          :name => item.unique_name,
          :quantity => item.quantity,
          :description => item.description,
          :minimum_stock => item.minimum_stock,
          :model_number => item.model_number,
          :has_stocks => item.has_stocks,
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
          :minimum_stock => item.minimum_stock,
          :has_stocks => item.has_stocks,
          :tags => item.tags,
          :requests => item.requests.map {
              |req| {
                :request_id => req.id,
                :user_id => req.user_id,
                :status => req.status
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

  def render_single_stock(input_stock)
    render :json => input_stock.instance_eval {
        |stock| {
          stock_id: stock.id,
          serial_tag: stock.serial_tag,
          item_id: stock.item_id,
          item_name: stock.item.unique_name,
          available: stock.available
      }
    }, status: 200
  end

  def render_multiple_stocks(stocks)
    render :json => stocks.map {
        |stock| {
          item_id: stock.item.id,
          stock_id: stock.id,
          item_name: stock.item.unique_name,
          serial_tag: stock.serial_tag,
          available: stock.available
      }
    }
  end

  private

  def update_min_stock_of_certain_items(items, stock_quantity)
    # binding.pry
    items.each do |item_temp|
      original_min_stock = Item.find(item_temp).minimum_stock
      if Item.find(item_temp).update!(:minimum_stock => stock_quantity)
      else
        render_client_error(@item.errors, 422) and return
      end
      minimum_stock_email_changed_min_stock(original_min_stock, item_temp.minimum_stock,item_temp)
    end
    render :json => items
  end

  def update_min_stock_of_certain_items_using_id(items, stock_quantity)
    # binding.pry
    new_item_array = []
    items.each do |item_temp|
      actual_item = Item.find(item_temp)
      original_min_stock = actual_item.minimum_stock
      if Item.find(item_temp).update!(:minimum_stock => stock_quantity)
      else
        render_client_error(@item.errors, 422) and return
      end
      new_item_array << Item.find(item_temp)
      minimum_stock_email_changed_min_stock(original_min_stock, actual_item.minimum_stock,actual_item)
    end
    render :json => new_item_array
  end
end