class TagsController < ApplicationController

  before_action :check_admin_user, only: [:create, :edit, :destroy]
  before_action :check_logged_in_user, only: [:show, :index]

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])

    outstanding_filter_params = {
        :item_id => @item.id,
        :status => "outstanding"
    }

    if !current_user.privilege_admin?
      outstanding_filter_params[:user] = current_user.username
    end

    @outstanding_item_requests = Request.filter(outstanding_filter_params)
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # DELETE /items/1
  def destroy
    Item.find(params[:id]).destroy
    flash[:success] = "Item deleted!"
    redirect_to items_url
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to item_url(@item)
    else

    end

    # if @user.save
    #   flash[:success] = "Welcome to the ECE Inventory family!"
    #   redirect_to @user
    # else
    #   render 'new'
    # end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(item_params)
      flash[:success] = "Item updated successfully"
      redirect_to @item
    else
      render 'edit'
    end
  end


  # Item.create([{ unique_name: 'f flesh', quantity: 10, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def tag_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:tag, {}).permit(:name)
  end

end

end
