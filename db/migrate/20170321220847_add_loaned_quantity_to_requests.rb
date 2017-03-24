class AddLoanedQuantityToRequests < ActiveRecord::Migration[5.0]
  def change
		add_column :items, :quantity_on_loan, :integer, default: 0
  end
end
