class CreateStockItemLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :stock_item_logs do |t|
			t.belongs_to :item_log
			t.belongs_to :stock
			t.string :old_serial_tag
			t.string :curr_serial_tag
    end

		add_column :item_logs, :has_stocks, :boolean, default: false

  end
end
