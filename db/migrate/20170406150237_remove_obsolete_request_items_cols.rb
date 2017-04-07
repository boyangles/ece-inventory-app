class RemoveObsoleteRequestItemsCols < ActiveRecord::Migration[5.0]
  def change
		remove_column :request_items, :request_type
		remove_column :request_items, :due_date
		remove_column :request_items, :approved_as

  end
end
