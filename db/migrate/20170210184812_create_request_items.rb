class CreateRequestItems < ActiveRecord::Migration[5.0]
  def change
    create_table :request_items do |t|
      t.belongs_to :request, index: true
      t.belongs_to :item, index: true
      t.timestamps
    end
  end
end
