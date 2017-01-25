class ChangeRequestsToTrackItemId < ActiveRecord::Migration[5.0]
  def change
    remove_column :requests, :item
    add_column :requests, :item_id, :int, unique: true
  end
end
