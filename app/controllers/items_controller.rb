class ItemsController < ApplicationController
  before_action :check_logged_in_user

  # GET /items
  # GET /items.json
  def index
    @tags = Tag.all
    
    @required_tag_filters = (params[:required_tag_names]) ? 
      params[:required_tag_names] : []
    @excluded_tag_filters = (params[:excluded_tag_names]) ?
      params[:excluded_tag_names] : []

    items_req = Item.tagged_with_all(@required_tag_filters).select("id")
    items_exc = Item.tagged_with_none(@excluded_tag_filters).select("id")
    items_req_and_exc = Item.where(:id => items_req & items_exc)

    @items = items_req_and_exc.
      filter_by_search(params[:search]).
      filter_by_model_search(params[:model_search]).
      order('unique_name ASC').paginate(page: params[:page], per_page: 10)
  end


  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])

    outstanding_filter_params = {
      :status => "outstanding"
    }

    if !current_user.privilege_admin?
      outstanding_filter_params[:user_id] = current_user.id
    end

    @requests = @item.requests.filter(outstanding_filter_params).paginate(page: params[:page], per_page: 10)
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
    Item.find(params[:id]).destroy!
    flash[:success] = "Item deleted!"
    redirect_to items_url
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

    add_tags_to_item(@item, params[:tag][:tag_id]) if params[:tag]
    remove_tags_from_item(@item, params[:tag_to_remove][:tag_id_remove]) if params[:tag_to_remove]

    if @item.save
      redirect_to item_url(@item)
    else
      flash.now[:danger] = "Unable to save!"
      render 'new'
    end
  end

  def update
    @item = Item.find(params[:id])

    add_tags_to_item(@item, params[:tag][:tag_id]) if params[:tag]
    remove_tags_from_item(@item, params[:tag_to_remove][:tag_id_remove]) if params[:tag_to_remove]

    if @item.update_attributes(item_params)
      flash[:success] = "Item updated successfully"
      redirect_to @item
    else
      flash.now[:danger] = "Unable to edit!"
      render 'edit'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:item, {}).permit(:unique_name, :quantity, :model_number, :description, :search, :model_search)
  end

end
