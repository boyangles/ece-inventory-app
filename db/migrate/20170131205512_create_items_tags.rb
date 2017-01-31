class CreateItemsTags < ActiveRecord::Migration[5.0]
  def change
    create_table :items_tags do |t|
      t.belongs_to :items, foreign_key: true
      t.belongs_to :tags, foreign_key: true
    end
  end
end
