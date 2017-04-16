class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
			t.belongs_to :request_item
			t.attachment :doc
    end
  end
end
