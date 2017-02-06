class ForeignKeyAddToRequest < ActiveRecord::Migration[5.0]
  def change
    add_reference :requests, :user, index:true, foreign_key: true
    add_reference :requests, :item, index:true, foreign_key: true

    add_reference :logs, :user, index:true, foreign_key: true
    add_reference :logs, :item, index:true, foreign_key: true
  end
end
