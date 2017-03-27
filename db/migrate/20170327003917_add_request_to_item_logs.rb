class AddRequestToItemLogs < ActiveRecord::Migration[5.0]
  def change
 		add_column :item_logs, :affected_request, :integer
  end
end
