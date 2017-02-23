class CustomFields < ActiveRecord::Migration[5.0]
  def change
    create_table :custom_fields do |t|
      t.string :field_name, null: false
      t.boolean :private_indicator, default: false, null: false
      t.integer :field_type, default: 0, null: false
    end

    add_index :custom_fields, :field_name, :unique => true

    create_table :item_custom_fields do |t|
      t.belongs_to :item, index: true
      t.belongs_to :custom_field, index: true

      t.text :short_text_content
      t.text :long_text_content
      t.integer :integer_content
      t.float :float_content
    end

    add_index :item_custom_fields, [:item_id, :custom_field_id], :unique => true

    add_foreign_key :item_custom_fields, :items
    add_foreign_key :item_custom_fields, :custom_fields
  end
end
