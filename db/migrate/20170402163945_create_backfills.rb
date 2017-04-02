class CreateBackfills < ActiveRecord::Migration[5.0]
  def change
    create_table :backfills do |t|
			t.belongs_to :request_item, index: true
			t.integer :quantity
			t.integer :bf_status
			t.integer :origin
    end
  end
end
