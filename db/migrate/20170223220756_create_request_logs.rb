class CreateRequestLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :request_logs do |t|
			t.belongs_to :log, index: true
			t.belongs_to :request, index: true
			t.integer :request_id
			t.integer :action
    end

		add_foreign_key :request_logs, :logs
  end
end
