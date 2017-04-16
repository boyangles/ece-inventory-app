class AttachmentsController < ApplicationController

	before_action :set_request, only: [:new]

	def index
		@attachments = Attachment.order('created_at')
	end

	def new
		@attachment = Attachment.new
	end

	def create
		@request = RequestItem.find(attachment_params[:request_item_id]).request

		begin
			@attachment = Attachment.new(attachment_params)

			if @attachment.valid?
				@attachment.save
				flash[:success] = "File uploaded!"
				redirect_to request_path(@attachment.request_item.request.id)
			else
				flash[:danger] = "Upload file not saved: Invalid File (Valid format is .jpg, .jpeg, .pdf)."
				redirect_to request_path(@request.id)
			end
		rescue ActiveRecord::RecordInvalid => invalid
			flash[:danger] = invalid.record.errors
			redirect_to request_path(@request.id)
		rescue Exception => e
			flash[:danger] = "Upload file not saved: #{e.message}"
			redirect_to request_path(@request.id)
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
