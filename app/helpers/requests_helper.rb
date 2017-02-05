module RequestsHelper
  def edit_request(request)
    respond_to do |format|
      if request.update(request_params)
        format.html { redirect_to request, notice: 'Request was successfully updated.' }
        format.json { render :show, status: :ok, location: request }
      else
        format.html { render :edit }
        format.json { render json: request.errors, status: :unprocessable_entity }
      end
    end
  end
end
