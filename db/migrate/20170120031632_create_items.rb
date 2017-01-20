class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
        t.string :unique_name
        t.integer :quantity
        t.integer :model_number
        t.string :description
        t.json 'tags'
        t.json 'instances'
    end
  end
end
