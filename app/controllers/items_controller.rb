class ItemsController < ApplicationController
  before_action :check_logged_in_user
  before_action :check_manager_or_admin, only: [:create, :new, :edit, :update, :set_all_minimum_stock]
  before_action :check_admin_user, only: [:destroy]

  # GET /items
  # GET /items.json
  def index
    @tags = Tag.all

    items_excluded = Item.all
    items_required = Item.all
    items_stocked = Item.all

    # 15.times do|i|
    #   puts "THE VALUE OF PARAMS STOCKED IS"
    #   puts params[:stocked]
    # end

    if params[:excluded_tag_names]
      @excluded_tag_filters = params[:excluded_tag_names]
      items_excluded = Item.tagged_with_none(@excluded_tag_filters).select(:id)
    end
    if params[:required_tag_names]
      @required_tag_filters = params[:required_tag_names]
      items_required = Item.tagged_with_all(@required_tag_filters).select(:id)
    end
    if params[:stocked]
      @stocked = params[:stocked]
      items_stocked = Item.minimum_stock
      # 15.times do|i|
      #   puts "YES"
      # end
    else
      # 15.times do|i|
      #   puts "NO"
      # end
    end

    items_active = Item.where(id: items_excluded & items_required & items_stocked).filter_active

    # 10.times do|i|
    #   puts "FUCK"
    #   items_active.minimum_stock.each do |item|
    #     puts item.unique_name
    #   end
    # end

    @items = items_active.
        filter_by_search(params[:search]).
        filter_by_model_search(params[:model_search]).
        order('unique_name ASC').paginate(page: params[:page], per_page: 10)

    # update_min_stock_of_certain_items(@items, 999)
  end

  # GET /items/1
  # GET /items/1.json
  def show
    if is_manager_or_admin?
      @item = Item.find(params[:id])
    else
      @item = Item.filter_active.find(params[:id])
    end

    # update_min_stock_of_certain_items(@item, 666)

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
    @item = Item.find(params[:id])
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
		if !@item.save!
			flash.now[:danger] = "Quantity unable to be changed"
			render 'edit'
		end
  end

  #probably needs to go in the model but testing here
  def set_all_minimum_stock

    # This code below is repeated but it is just used to search for stuff.
    #TODO: Refactor later
    @tags = Tag.all

    items_excluded = Item.all
    items_required = Item.all
    items_stocked = Item.all
    if params[:excluded_tag_names]
      @excluded_tag_filters = params[:excluded_tag_names]
      items_excluded = Item.tagged_with_none(@excluded_tag_filters).select(:id)
    end
    if params[:required_tag_names]
      @required_tag_filters = params[:required_tag_names]
      items_required = Item.tagged_with_all(@required_tag_filters).select(:id)
    end
    if params[:stocked]
      @stocked = params[:stocked]
      items_stocked = Item.minimum_stock
    else
    end
    items_active = Item.where(id: items_excluded & items_required & items_stocked).filter_active

    # do we really wanna paginate?
    @items = items_active.
        filter_by_search(params[:search]).
        filter_by_model_search(params[:model_search]).
        order('unique_name ASC').paginate(page: params[:page], per_page: 10)


    @items = items_active.
        filter_by_search(params[:search]).
        filter_by_model_search(params[:model_search]).
        order('unique_name ASC')

  end

  def update_all_minimum_stock
    #Putting this line below just to test! Need to verify that it works.
    items = Item.all
    # binding.pry
    # 10000.times do |i|
    #   puts "The value of items is "
    #   puts items
    #   puts "The value of params is "
    #   puts params[:min_quantity]
    # end

    if !params[:item_ids].nil? && !params[:min_quantity].empty?
      update_min_stock_of_certain_items(params[:item_ids], params[:min_quantity])
    end
    # Item.update_all(:minimum_stock => @stock_quantity)
    # puts Item.all

    redirect_to minimum_stock_path
  end

  ## helper method that will be used to update stocks and shit.
  def update_min_stock_of_certain_items(items, stock_quantity)
    # binding.pry
    items.each do |i|
      Item.find(i).update!(:minimum_stock => stock_quantity)
    end
  end
  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:item, {}).permit(	:unique_name,
																	  :quantity,
																		:model_number, 
																		:description,
                                     :minimum_stock,
																		:search, 
																		:model_search, 
																		:status, 
																		:last_action,
																		:tag_list=>[],
																		item_custom_fields_attributes: [:short_text_content,
																																		 :long_text_content,
																																		 :integer_content,
																																		 :float_content,
																																		 :item_id, :custom_field_id, :id])
  end

end
