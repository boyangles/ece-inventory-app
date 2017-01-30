class ItemsController < ApplicationController
  before_action :check_approved_user

  # GET /items
  # GET /items.json
  def index
    @items = Item.paginate(page: params[:page], per_page: 10)
  end


  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])
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
  def item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:item, {}).permit(:unique_name, :quantity, :model_number, :description)
  end

end
