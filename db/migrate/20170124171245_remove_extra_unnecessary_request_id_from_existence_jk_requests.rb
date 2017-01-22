class RemoveExtraUnnecessaryRequestIdFromExistenceJkRequests < ActiveRecord::Migration[5.0]
  def change
	remove_column :requests, :req_id
  end
end
