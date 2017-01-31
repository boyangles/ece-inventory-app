class ConvertStatusAndPrivilegeForUserToEnums < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :status
    remove_column :users, :privilege
    
    add_column :users, :status, :integer, default: 0
    add_column :users, :privilege, :integer, default: 0
  end
end
