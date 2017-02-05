class LogIdsToNames < ActiveRecord::Migration[5.0]
  def change
    remove_column :logs, :item_id
    remove_column :logs, :user_id

    add_column :logs, :item_name, :string
    add_column :logs, :user, :string
  end
end
