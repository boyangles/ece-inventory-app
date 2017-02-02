class ItemsController < ApplicationController
  before_action :check_approved_user

  before_action :check_logged_in_user, only: [:show]

  # GET /items
  # GET /items.json
  def index
    @items = Item.order('unique_name ASC').paginate(page: params[:page], per_page: 10)
  end


  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])

    outstanding_filter_params = {
      :item_name => @item.unique_name,
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
  end

  def update
    @item = Item.find(params[:id])

    add_tags_to_item
    remove_tags_from_item

    if @item.update_attributes(item_params)
      flash[:success] = "Item updated successfully"
      redirect_to @item
    else
      render 'edit'
    end
  end


  private

  # adds tags based on what has been selected in update item
  def add_tags_to_item
    if params[:tag]
      params[:tag][:tag_id].each do |tag|
        if tag.present?
          @tag = Tag.find(tag)
          @item.tags << @tag
        end
      end
    end
  end

  # removes tags from item based on selection
  def remove_tags_from_item
    if params[:tag_to_remove]
      params[:tag_to_remove][:tag_id_remove].each do |tag|
        if tag.present?
          @tag = Tag.find(tag)
          @item.tags.delete(@tag)
        end
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:item, {}).permit(:unique_name, :quantity, :model_number, :description)
  end

end
