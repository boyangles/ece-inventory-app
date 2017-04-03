class CreateAssets < ActiveRecord::Migration[5.0]
  def change
    create_table :assets do |t|
      t.belongs_to :item
      t.boolean :available
      t.string :serial_tag, unique: true

      t.timestamps
    end

    create_table :asset_custom_fields do |t|
      t.belongs_to :asset, index: true
      t.belongs_to :custom_field, index: true
      t.text    :short_text_content
      t.text    :long_text_content
      t.integer :integer_content
      t.float   :float_content
    end

    add_column :custom_fields, :is_asset, :boolean

    add_index :asset_custom_fields, [:asset_id, :custom_field_id], :unique => true

    add_foreign_key :asset_custom_fields, :assets
    add_foreign_key :asset_custom_fields, :custom_fields

  end
end
