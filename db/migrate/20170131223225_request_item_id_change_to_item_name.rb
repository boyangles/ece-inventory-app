class RequestItemIdChangeToItemName < ActiveRecord::Migration[5.0]
  def change
      remove_column :requests, :item_id
      add_column :requests, :item_name, :string, unique: true
  end
end
