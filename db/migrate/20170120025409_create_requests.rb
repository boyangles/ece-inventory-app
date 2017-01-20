class CreateRequests < ActiveRecord::Migration[5.0]
    def change
        create_table :requests do |t|
            t.integer :req_id
            t.time :datetime
            t.string :user
            t.string :item
            t.integer :quantity
            t.string :reason
            t.string :status
            t.string :request_type
            t.json 'instances'
            t.timestamps
        end
    end
end
