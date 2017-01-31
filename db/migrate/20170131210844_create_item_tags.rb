class CreateItemTags < ActiveRecord::Migration[5.0]
  def change
    create_table :item_tags do |t|
      t.belongs_to :tag, index: true
      t.belongs_to :item, index: true
      t.timestamps
    end
  end
end
