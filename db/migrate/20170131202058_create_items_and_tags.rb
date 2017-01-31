class CreateItemsAndTags < ActiveRecord::Migration[5.0]
  def change
    create_table :items_and_tags, id: false do |t|
      t.belongs_to :item, foreign_key: true
      t.belongs_to :tag, foreign_key: true
    end
  end
end
