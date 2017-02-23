class CreateUserCarts < ActiveRecord::Migration[5.0]
  def change
    create_table :user_carts do |t|
	t.integer :user_id, unique: true
	t.integer :cart_id, unique: true
  	t.timestamps
    end

    add_foreign_key :user_carts, :users, column: :user_id, unique: true
    add_foreign_key :user_carts, :requests, column: :cart_id, unique: true
  end
end
