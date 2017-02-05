class AddLocationColumnToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :location, :string
  end
end
