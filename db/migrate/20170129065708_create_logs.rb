class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.time :datetime
      t.integer :req_id, unique: true
      t.string :user
      t.integer :item_id, unique: true
      t.integer :quantity
      t.string :request_type
      t.timestamps
    end
  end
end
