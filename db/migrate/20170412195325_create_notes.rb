class CreateNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :notes do |t|
      t.integer :user_id
      t.string  :description
      t.belongs_to :request_item
      t.timestamps
  end
end
