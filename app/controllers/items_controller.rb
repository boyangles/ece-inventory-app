class ItemsController < ApplicationController
  before_action :check_logged_in_user
  before_action :check_manager_or_admin, only: [:create, :new, :edit, :update]
  before_action :check_admin_user, only: [:destroy]
  before_action :set_item,  only: [:edit, :edit_quantity, :update, :create_stocks, :convert_to_global, :convert_to_stocks]

  # GET /items
  # GET /items.json
  def index
    @tags = Tag.all

    items_excluded = Item.all
    items_required = Item.all
    if params[:excluded_tag_names]
      @excluded_tag_filters = params[:excluded_tag_names]
      items_excluded = Item.tagged_with_none(@excluded_tag_filters).select(:id)
    end
    if params[:required_tag_names]
      @required_tag_filters = params[:required_tag_names]
      items_required = Item.tagged_with_all(@required_tag_filters).select(:id)
    end

    items_active = Item.where(id: items_excluded & items_required).filter_active

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
    @item_custom_fields = (@item.has_stocks) ?
        ItemCustomField.filter({ item_id: @item.id, is_global: true }) :
        ItemCustomField.filter({item_id: @item.id})
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
    @item_custom_fields = ItemCustomField.where(item_id: @item.id)
  end

  def edit_quantity

  end

  # DELETE /items/1
  def destroy

    # Delete stocks with destroy_stocks_by_serial_tags! - surround with try catch

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
      flash[:success] = "Bulk Import Successful"
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
    @item.curr_user = current_user

    @item.tags.delete_all
    add_tags_to_item(@item, item_params)

    if @item.update_attributes(item_params)
      if !params[:quantity_change].nil?
        update_quantity
      end

      flash[:success] = "Item updated successfully"
      puts(@item.last_action)
      redirect_to @item
    else
      flash.now[:danger] = "Unable to edit!"
      render 'edit'
    end
  end
 
 

  def update_quantity
    @item.quantity = @item.quantity + params[:quantity_change].to_f
    if !@item.save
      flash.now[:danger] = "Quantity unable to be changed"
      render 'edit'
    end

  end

  def convert_to_stocks
    if @item.convert_to_stocks
      flash[:success] = "Item successfully converted to Assets!"
      redirect_to item_stocks_path(@item)
    else
      flash.now[:danger] = "Item already converted to Assets"
      render :show
    end
  end

  def convert_to_global
    if @item.convert_to_global
      flash[:success] = "Item successfully converted to global"
      redirect_to item_path(@item)
    else
      flash.now[:danger] = "Item already global"
      render :show
    end
  end

  # changed in accordance to https://piazza.com/class/ixtuwsa7f0d3d9?cid=118
  # change back to create_stocks, and alter stocks/index.html.erb to use number_field_tag, and all should be back if necessary
  def create_stocks_deprecated
    begin
      throw Exception.new('Number must be greater than 0') if params[:num_stocks].to_i <= 0
      Stock.create_stocks!(params[:num_stocks].to_i, params[:id])
      flash[:success] = "(#{params[:num_stocks]}) Assets successfully created!"
      redirect_to item_stocks_path @item
      return true
    rescue Exception => e
      flash[:danger] = e.message
      redirect_to item_stocks_path @item
      return false
    end
  end

  # The method for creating a single stock by user specifying the serial_tag as params[:num_stocks] (confusing bc changed and didn't want to alter the entire params if we want to change back)
  def create_stocks
    begin
      @item.create_stock(params[:num_stocks])
      flash[:success] = "(#{params[:num_stocks]}) Asset successfully created!"
      redirect_to item_stocks_path @item.id
      return true
    rescue Exception => e
      flash[:danger] = e.message
      redirect_to item_stocks_path @item
      return false
    end
  end


  private

  def set_item
    @item = Item.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:item, {}).permit(	:unique_name,
                                     :quantity,
                                     :model_number,
                                     :description,
                                     :search,
                                     :model_search,
                                     :status,
                                     :last_action,
                                     :has_stocks,
                                     :num_stocks,
                                     :tag_list=>[],
                                     item_custom_fields_attributes: [:short_text_content,
                                                                     :long_text_content,
                                                                     :integer_content,
                                                                     :float_content,
                                                                     :item_id, :custom_field_id, :id])
  end

end
