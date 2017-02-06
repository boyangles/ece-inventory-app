class ChangeModelNumberTypeToStringForItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :model_number
    add_column :items, :model_number, :string
  end
end
