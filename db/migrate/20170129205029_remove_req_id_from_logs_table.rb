class RemoveReqIdFromLogsTable < ActiveRecord::Migration[5.0]
  def change
    remove_column :logs, :req_id
  end
end
