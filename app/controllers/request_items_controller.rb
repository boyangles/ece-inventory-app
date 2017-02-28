class RequestItemsController < ApplicationController
  before_action :check_logged_in_user

  def new
    @request_item = RequestItem.new

    if !params[:item_id].blank?
      @request_item[:item_id] = params[:item_id]
    end

		if !RequestItem.where(item_id: params[:item_id]).where(request_id: grab_cart(current_user).id).take.nil?
			flash[:warning] = "This item has already been added to your cart! Edit cart to increase quantity."
			redirect_to request_path(grab_cart(current_user).id)
		else
    	# look for cart to link request to item
    	@request = grab_cart(current_user)
    	@request_item[:request_id] = @request.id
		end

  end

  def create

   	@request_item = RequestItem.new(request_item_params) #make private def later
    	if @request_item.save
				@request = grab_cart(current_user)
    		redirect_to request_path(@request.id)
			else
      	flash.now[:danger] = "You may not add this to the cart!"
      	render 'new'
			end
  end

	def destroy
		reqit = RequestItem.find(params[:id])
		req = Request.find(reqit.request_id)
		reqit.destroy!
		flash[:success] = "Item removed from request!"
		redirect_to request_path(req)
	end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:request_item, {}).permit(:quantity, :item_id, :request_id)
  end

end
