class Attachment < ApplicationRecord
	belongs_to :request_item
	
	has_attached_file :doc
	validates_attachment_content_type :doc, :content_type => ["application/pdf"]
	validates_attachment_file_name :doc, matches: [/pdf\z/]

end
