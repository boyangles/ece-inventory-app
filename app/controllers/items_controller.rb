class ItemsController < ApplicationController
  before_action :check_logged_in_user
  before_action :check_manager_or_admin, only: [:create, :new, :edit, :update]
  before_action :check_admin_user, only: [:destroy]

  # GET /items
  # GET /items.json
  def index
    @tags = Tag.all

    @required_tag_filters = params["/items"] ? ( params["/items"][:required_tag_names] ?
        params["/items"][:required_tag_names] : [] ) : []
    @excluded_tag_filters = params["/items"] ? ( params["/items"][:excluded_tag_names] ?
        params["/items"][:excluded_tag_names] : [] ) : []

    # Plug in Chosen populates array with first element '' always. Shift left to remove it.
    @required_tag_filters.shift
    @excluded_tag_filters.shift

    items_req = Item.tagged_with_all(@required_tag_filters).select("id")
    items_exc = Item.tagged_with_none(@excluded_tag_filters).select("id")
    items_req_and_exc = Item.where(:id => items_req & items_exc)
    items_active = items_req_and_exc.filter_active

    @items = items_active.
        filter_by_search(params[:search]).
        filter_by_model_search(params[:model_search]).
        order('unique_name ASC').paginate(page: params[:page], per_page: 10)
  end


  # GET /items/1
  # GET /items/1.json
  def show
    if is_manager_or_admin?
      @item = Item.find(params[:id])
    else
      @item = Item.filter_active.find(params[:id])
    end

    outstanding_filter_params = {
        :status => "outstanding"
    }

    if !is_manager_or_admin?
      outstanding_filter_params[:user_id] = current_user.id
    end

    @requests = @item.requests.filter(outstanding_filter_params).paginate(page: params[:page], per_page: 10)
    @item_custom_fields = ItemCustomField.where(item_id: @item.id)
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
    @item_custom_fields = ItemCustomField.where(item_id: @item.id)
  end

  def edit_quantity
    @item = Item.find(params[:id])
  end

  # DELETE /items/1
  def destroy
    item = Item.find(params[:id]).status = 'deactive'
    item.save!
    flash[:success] = "Item deleted!"
    redirect_to items_url
  end


  # POST /items
  # POST /items.json
	def create
		begin

			ActiveRecord::Base.transaction do
				@item = Item.new(item_params)
				@item.last_action = "created"
				@item.curr_user = current_user

				add_tags_to_item(@item, item_params)
				@item.save!

				CustomField.all.each do |cf|
					cf_name = cf.field_name
					icf = ItemCustomField.find_by(:item_id => @item.id, :custom_field_id => cf.id)
					icf.update_attributes!(CustomField.find_icf_field_column(cf.id) => params[cf_name])
				end
			end

      redirect_to item_url(@item.id)

		rescue Exception => e
			flash.now[:danger] = e.message
			
			render 'new'
		end

	end


  def import_upload

  end

  def bulk_import
    begin
      Item.bulk_import(params[:items_as_json].read)
      redirect_to items_path
    rescue NoMethodError => nme
      @imported_error_msg = "Must input a file"
      render 'import_upload'
    rescue Exception => e
      @imported_error_msg = e.message
      render 'import_upload'
    end
  end

  def update
    @item = Item.find(params[:id])
    @item.curr_user = current_user

    @item.tags.delete_all
    add_tags_to_item(@item, item_params)

    if @item.update_attributes(item_params)
      flash[:success] = "Item updated successfully"
      puts(@item.last_action)
      redirect_to @item
    else
      flash.now[:danger] = "Unable to edit!"
      render 'edit'
    end
  end

  def update_quantity
    @item = Item.find(params[:id])

    # add action to last_action

    if @item.update_attributes(item_params)
      flash[:success] = "Item updated successfully"
      redirect_to @item
    else
      flash.now[:danger] = "Unable to edit!"
      render 'edit_quantity'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:item, {}).permit(:unique_name, :quantity, :model_number, :description, :search, :model_search, :status, :last_action, :tag_list=>[])
  end

end
