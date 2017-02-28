class ModifyingLogsToGlobal < ActiveRecord::Migration[5.0]
  def change
		remove_column :logs, :quantity
		remove_column :logs, :request_type
		remove_column :logs, :item_id

		add_column :logs, :log_type, :integer, default: 0

  end
end
