class CreateStackExchanges < ActiveRecord::Migration[5.0]
  def change
    create_table :stack_exchanges do |t|

      t.timestamps
    end
  end
end
