class RequestItemsController < ApplicationController
  before_action :check_logged_in_user
	before_action :set_new_quantity, only: [:update]

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
    	if @request_item.save!
				@request = grab_cart(current_user)
    		redirect_to request_path(@request.id)
			else
      	flash.now[:danger] = "You may not add this to the cart!"
      	render 'new'
			end
  end

	def update
		@request_item = RequestItem.find(params[:id])

		respond_to do |format|
			if @request_item.update_attributes(request_item_params)
				format.html { redirect_to @request_item.request, notice: "Item quantity updated successfully."	}
				format.json { head :no_content }
			else
				format.html { redirect_to @request_item.request, alert: "Failed updating quantity" } 
				format.json { render json: @request_item.errors, status: :unprocessable_entity }
			end
		end
	end

	def show

	end

	def destroy
		reqit = RequestItem.find(params[:id])
		req = Request.find(reqit.request_id)
		reqit.destroy!
		flash[:success] = "Item removed from request!"
		redirect_to request_path(req)
	end

	def return
		reqit = RequestItem.find(params[:id])
		UserMailer.loan_convert_email(reqit)
		if (params[:quantity_to_return].to_f > reqit.quantity_loan)
			flash[:danger] = "That's more than are loaned out!"
		else
			reqit.return_subrequest(params[:quantity_to_return].to_f)
			flash[:success] = "Quantity successfully returned!"
		end		
		redirect_to request_path(reqit.request_id)
	end

	def disburse_loaned 
		reqit = RequestItem.find(params[:id])
		if (params[:quantity_to_disburse].to_f > reqit.quantity_loan)
			flash[:danger] = "That's more than are loaned out!"
		else
			reqit.disburse_loaned_subrequest(params[:quantity_to_disburse].to_f)
			flash[:success] = "Quantity successfully disbursed!"
		end		
		redirect_to request_path(reqit.request_id)
	end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:request_item, {}).permit(:quantity_loan, :quantity_disburse, :quantity_return, :item_id, :request_id, :quantity_to_return, :quantity_to_disburse)
  end

	def set_new_quantity
		@request_item = RequestItem.find(params[:id])
	end

end
