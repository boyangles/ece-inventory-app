class LoansController < ApplicationController
  def index		

		requests = Request.where(status: "approved")

		if !is_manager_or_admin? 
			requests = requests.where(user_id: current_user.id)
		end

		if !requests.nil? 
			@loans = RequestItem.where("quantity_loan > ?", 0).where(request_id: requests.select(:id)).order(:updated_at).paginate(page: params[:page], per_page: 10)
		else
			@loans = loansoo
		end	
  end

end
