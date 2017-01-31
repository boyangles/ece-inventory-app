class RequestTableEnums < ActiveRecord::Migration[5.0]
  def change
    remove_column :requests, :status
    remove_column :requests, :request_type

    add_column :requests, :status, :integer, default: 0
    add_column :requests, :request_type, :integer, default: 0 
  end
end
