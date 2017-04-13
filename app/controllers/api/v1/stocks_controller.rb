class Api::V1::StocksController < BaseController
before_action :authenticate_with_token!
before_action :auth_by_approved_status!
before_action :auth_by_manager_privilege!, only: []
before_action :auth_by_admin_privilege!, only: []
before_action :render_404_if_stock_unknown, only: []
before_action :set_stock, only: []

protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

[].each do |api_action|
  swagger_api api_action do
    param :header, :Authorization, :string, :required, 'Authentication token'
  end
end

respond_to :json

swagger_controller :stocks, 'Stocks'

swagger_api :index do
  summary 'Returns all or specified Stocks'
  notes ""
  param :query, :search, :string, :optional, "Search by Serial Tag"
  param :query, :available_search, :string, :optional, "Search by Model Number"
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
  param :form, 'item[description]', :string, :optional, "Item Description"
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
    Updates general attributes associated with an item (item name, description, and model number).
    These updates are all optional. If none are filled out, then the item simply doesn't update.
    "
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
end
