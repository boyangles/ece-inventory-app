class BackfillComments < ActiveRecord::Migration[5.0]
  def change
    create_table :request_item_comments do |t|
      t.belongs_to :request_item
      t.string :comment
    end
  end
end
