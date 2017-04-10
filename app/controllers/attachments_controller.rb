class AttachmentsController < ApplicationController

	def index
		@attachments = Attachment.order('created_at')
	end

	def new
		@attachment = Attachment.new
	end

	def create
		@attachment = Attachment.create( attachment_params )

		if @attachment.save!
			flash[:success] = "File uploaded!"
			redirect_to request_path(@attachment.request_item.request.id) 
		else
			render loans_index_path
		end
	end

	private
	
	def attachment_params
		params.require(:attachment).permit(:doc, :request_item_id)
	end

end
