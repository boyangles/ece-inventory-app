class BackfillsController < ApplicationController

	def index
		@backfills = Backfill.all
	end

	def new
		@backfill = Backfill.new
	end

	def create
		@backfill = Backfill.new(backfill_params)

		@backfill.save!
		request = @backfill.request_item.request
		redirect_to request_path(request.id)
	end

	def update
		@backfill = Backfill.find(params[:id])

		if @backfill.update!(backfill_params)

		else
		
		end
	end

	def destroy
		@backfill = Backfill.find(params[:id])
		request = @backfill.request_item.request
		@backfill.destroy

		redirect_to request_path(request.id)
	end	

	private
		def backfill_params
			params.require(:backfill).permit(:quantity, :status)
		end

end
