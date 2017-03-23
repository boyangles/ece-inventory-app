class LoansController < ApplicationController
  def index		

		if !is_manager_or_admin? 
			loansoo = Request.where(user_id: current_user.id)
		else
			loansoo = Request.all
		end

		loansaaa = Request.where(status: "approved").where(id: RequestItem.select(:request_id).where("quantity_loan > ?", 0))

		@loans = (loansoo and loansaaa).order(:updated_at).paginate(page: params[:page], per_page: 10)
  end
end
