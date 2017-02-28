class RemoveLogFromUserForeignKey < ActiveRecord::Migration[5.0]
  def change
		remove_foreign_key :logs, :users
  end
end
