class AttachmentsController < ApplicationController

	before_action :set_request, only: [:new]

	def index
		@attachments = Attachment.order('created_at')
	end

	def new
		@attachment = Attachment.new
	end

	def create
		begin
			@attachment = Attachment.new(attachment_params)
			@attachment.save!
			flash[:success] = "File uploaded!"
			redirect_to request_path(@attachment.request_item.request.id)
		rescue Exception => e
			flash.now[:danger] = "Upload file not saved: #{e.message}"
			render request_path(@request.id)
		end
	end

	def destroy
		@attachment = Attachment.find(params[:id])
		request = @attachment.request_item.request
		@attachment.destroy
		flash[:success] = "File Removed!"
		redirect_to request_path(request.id)
	end

	private

	def set_request
		@request = Request.find(params[:id])
	end

	def attachment_params
		params.require(:attachment).permit(:doc, :request_item_id)
	end

end
