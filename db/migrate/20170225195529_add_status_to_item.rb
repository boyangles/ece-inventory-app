class AddStatusToItem < ActiveRecord::Migration[5.0]
  def change
		add_column :items, :status, :integer, default: 0
  end
end
