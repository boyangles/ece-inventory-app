class LoansController < ApplicationController
  def index		

		requests = Request.where(status: "approved")

		if !is_manager_or_admin? 
			requests = requests.where(user_id: current_user.id)
		end

		if !requests.nil?

			loans_indeed = RequestItem.where(bf_status: "loan").select(:id)
			denied = RequestItem.where(bf_status: "bf_denied").select(:id)
			failed = RequestItem.where(bf_status: "bf_failed").select(:id)
 
			firstLayer = RequestItem.where("quantity_loan > ?", 0).where(id: loans_indeed | denied | failed).where(request_id: requests.select(:id))

			loans_items =  RequestItem.where(item_id: Item.select(:id).where("unique_name ILIKE ?", "%#{params[:search_item]}%"))
			loans_users = RequestItem.where(request_id: Request.select(:id).where(user_id: User.select(:id).where("username ILIKE ?", "%#{params[:search_user]}%")))


			if !params[:search_item].blank? && params[:search_user].blank?
				secondLayer = (firstLayer &	loans_items)
			elsif !params[:search_user].blank? && params[:search_item].blank?
				secondLayer = (firstLayer & loans_users)
			elsif !params[:search_item].blank? && !params[:search_user].blank?
				secondLayer = (firstLayer & loans_users & loans_items)
			else
				secondLayer = firstLayer
			end
				
			@loans = RequestItem.where(id: secondLayer).order(:updated_at).paginate(page: params[:page], per_page: 10)
		else
			@loans = loansoo
		end	
  end

end
