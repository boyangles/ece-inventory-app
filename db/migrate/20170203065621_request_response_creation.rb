class RequestResponseCreation < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :response, :string
  end
end
