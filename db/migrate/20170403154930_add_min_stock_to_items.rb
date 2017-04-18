class AddMinStockToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :minimum_stock, :integer, default: 0
  end
end
