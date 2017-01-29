class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]

  # GET /requests
  # GET /requests.json
  def index
    @requests = Request.all
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
  end

  # GET /requests/new
  def new
    @request = Request.new
    
    if !params[:item_id].blank?
      @request[:item_id] = params[:item_id]
      @item = Item.find(@request.item_id)
    end
    
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
    @item = Item.find(@request.item_id)
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(request_params)
    @user = current_user

    # Set default values for requests:
    @request.user = @user.username
    @request.datetime = Time.now
    @request.status = "outstanding"
    # @request.request_type = ??? what is this?


    respond_to do |format|
      if @request.save
        format.html { redirect_to @request, notice: 'Request was successfully created.' }
        format.json { render :show, status: :created, location: @request }
      else
        format.html { render :new }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    respond_to do |format|
      if @request.update(request_params)
        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
        format.json { render :show, status: :ok, location: @request }
      else
        format.html { render :edit }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to requests_url, notice: 'Request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  
 
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      params.fetch(:request, {}).permit(:datetime, :user, :item_id, :quantity, :reason, :status, :request_type, :instances)
    end
end
