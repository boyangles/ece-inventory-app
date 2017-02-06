class ForeignKeyAddToRequest < ActiveRecord::Migration[5.0]
  def change
    add_reference :requests, :user, foreign_key: true
    add_reference :requests, :item, foreign_key: true

    add_reference :logs, :user, foreign_key: true
    add_reference :logs, :item, foreign_key: true

    add_index :requests, [:user_id, :item_id, :created_at]
    add_index :logs, [:user_id, :item_id, :created_at]
  end
end
