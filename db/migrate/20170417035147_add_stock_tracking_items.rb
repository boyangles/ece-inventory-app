class AddStockTrackingItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :stock_threshold_tracked, :boolean, default: false
  end
end
