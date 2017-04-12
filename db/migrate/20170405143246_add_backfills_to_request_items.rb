class AddBackfillsToRequestItems < ActiveRecord::Migration[5.0]
  def change
		add_column :request_items, :bf_status, :integer, default: 0
		add_column :request_items, :approved_as, :integer
  end
end
