class Attachment < ApplicationRecord
	belongs_to :request_item
	
	has_attached_file :doc
	validates_attachment_content_type :doc, :content_type => ['application/pdf', 'image/jpeg']
	validates_attachment_file_name :doc, matches: [/pdf\z/, /jpe?g\z/]

	scope :request_item_id, -> (request_item_id) { where request_item_id: request_item_id }
end
