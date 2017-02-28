class AddCurrQuantityToItemLogs < ActiveRecord::Migration[5.0]
  def change
		add_column :item_logs, :curr_quantity, :integer
  end
end
