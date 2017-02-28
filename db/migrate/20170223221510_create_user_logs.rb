class CreateUserLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :user_logs do |t|
	t.belongs_to :log, index: true
	t.belongs_to :user, index: true
	t.integer :user_id
	t.integer :action
	t.integer :old_privilege
	t.integer :new_privilege
	t.timestamps
    end

		add_foreign_key :user_logs, :logs
  end
end
