class RemoveDatetimeFieldFromLogsAndRequests < ActiveRecord::Migration[5.0]
  def change
    remove_column :logs, :datetime
    remove_column :requests, :datetime
  end
end
