class AddLastActionToItems < ActiveRecord::Migration[5.0]
  def change
		add_column :items, :last_action, :integer

  end
end
