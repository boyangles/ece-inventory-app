class CreateRequestItemStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :request_item_stocks do |t|
      t.belongs_to :stock
      t.belongs_to :request_item
      t.integer :status, default: 0, null: false
      t.timestamps
    end
  end
end
