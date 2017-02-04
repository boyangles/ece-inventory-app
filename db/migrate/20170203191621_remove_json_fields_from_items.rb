class RemoveJsonFieldsFromItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :instances
    remove_column :items, :available_tags
  end
end
