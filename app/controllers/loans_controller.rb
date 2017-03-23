class LoansController < ApplicationController
  def index		

		requests = Request.where(status: "approved")

		if !is_manager_or_admin? 
			loansoo = requests.where(user_id: current_user.id)
		end

		@loans = RequestItem.where("quantity_loan > ?", 0).where(request_id: loansoo.select(:id)).order(:updated_at).paginate(page: params[:page], per_page: 10)
		
  end
end
