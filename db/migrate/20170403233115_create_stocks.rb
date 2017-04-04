class CreateStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :stocks do |t|
      t.belongs_to :item
      t.boolean :available
      t.string :serial_tag, unique: true

      t.timestamps
    end

    create_table :stock_custom_fields do |t|
      t.belongs_to :stock, index: true
      t.belongs_to :custom_field, index: true
      t.text    :short_text_content
      t.text    :long_text_content
      t.integer :integer_content
      t.float   :float_content
    end

    add_column :items, :is_stock, :boolean, default: false
    add_column :custom_fields, :is_stock, :boolean

    add_index :stock_custom_fields, [:stock_id, :custom_field_id], :unique => true

    add_foreign_key :stock_custom_fields, :stocks
    add_foreign_key :stock_custom_fields, :custom_fields

  end
end
