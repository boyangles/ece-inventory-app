class ItemRenameTagsColumn < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :tags
    add_column :items, :available_tags, :json
  end
end
