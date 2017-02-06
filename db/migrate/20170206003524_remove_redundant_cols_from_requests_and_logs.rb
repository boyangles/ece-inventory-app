class RemoveRedundantColsFromRequestsAndLogs < ActiveRecord::Migration[5.0]
  def change
    remove_column :logs, :item_name
    remove_column :logs, :user
    remove_column :requests, :item_name
    remove_column :requests, :user
  end
end
