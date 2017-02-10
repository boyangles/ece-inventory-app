class MoveQuantityToRequestItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :requests, :quantity
    add_column :request_items, :quantity, :integer, default: 0
  end
end
