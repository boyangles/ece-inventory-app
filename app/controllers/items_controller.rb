class ItemsController < ApplicationController
  # before_action :set_user, only: [:show, :edit, :update, :destroy]
  # # Editing/updating a user credential only can be done when logged in
  # before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  # before_action :correct_user, only: [:edit, :update]
  # # Security issue: only admin users can delete users
  # before_action :admin_user, only: :destroy

  # GET /items
  # GET /items.json
  def index
    @items = Item.all
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

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

  end

end
