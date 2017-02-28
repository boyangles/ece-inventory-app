class CreateItemLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :item_logs do |t|
  		t.belongs_to :log, index: true
		t.belongs_to :item, index: true
			t.integer :item_id
			t.integer :action
			t.integer :quantity_change
			t.string :old_name
			t.string :new_name
			t.string :old_desc
			t.string :new_desc
			t.string :old_model_num
			t.string :new_model_num
	  end

		add_foreign_key :item_logs, :logs
  end
end
