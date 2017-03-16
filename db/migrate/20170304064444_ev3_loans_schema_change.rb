class Ev3LoansSchemaChange < ActiveRecord::Migration[5.0]
  def change
    remove_column :requests, :request_type

    remove_column :request_items, :quantity
    add_column :request_items, :quantity_loan, :integer, default: 0
    add_column :request_items, :quantity_disburse, :integer, default: 0
    add_column :request_items, :quantity_return, :integer, default: 0
    add_column :request_items, :request_type, :integer, default: 0
    add_column :request_items, :due_date, :datetime

    add_column :requests, :request_initiator, :integer, null: false

    add_index :requests, :request_initiator

    add_foreign_key :requests, :users, column: :request_initiator
  end
end
