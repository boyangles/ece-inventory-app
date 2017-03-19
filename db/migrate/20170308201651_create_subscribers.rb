class CreateSubscribers < ActiveRecord::Migration[5.0]
  def change
    create_table :subscribers do |t|
      t.integer :user_id
      t.timestamps
    end

    add_foreign_key :subscribers, :users
  end
end
