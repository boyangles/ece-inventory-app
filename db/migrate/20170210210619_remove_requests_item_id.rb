class RemoveRequestsItemId < ActiveRecord::Migration[5.0]
  def change
		remove_column :requests, :item_id
  end
end
