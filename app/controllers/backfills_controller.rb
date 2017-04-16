class BackfillsController < ApplicationController

	def index
		waiting = RequestItem.where(bf_status: "bf_request").select(:id)
		in_transit = RequestItem.where(bf_status: "bf_in_transit").select(:id)
		satisfied = RequestItem.where(bf_status: "bf_satisfied").select(:id)

		backfills_active = RequestItem.where(id: waiting | in_transit | satisfied)

		if !is_manager_or_admin?
			backfills_active = backfills_active.where(request_id: Request.where(user_id: current_user.id).select(:id))
		end

		if !backfills_active.nil? 
			@backfills = backfills_active.paginate(page: params[:page], per_page: 10) 
		end

	end

end
