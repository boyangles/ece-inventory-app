class LogSchemaChangeForRequestTypeAndUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :logs, :user
    remove_column :logs, :request_type

    add_column :logs, :user_id, :int
    add_column :logs, :request_type, :integer, default: 0

    add_index :logs, :req_id, unique: true
  end
end
