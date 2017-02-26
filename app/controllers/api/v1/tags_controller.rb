class Api::V1::TagsController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:create, :update, :destroy]
  before_action :render_404_if_tag_unknown, only: [:show, :update, :destroy]
  before_action :set_tag, only: [:show, :update, :destroy]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :tags, 'Tags'

  swagger_api :index do
    summary 'Returns all Tags'
    notes 'Search tags'
    param :query, :name, :string, :optional, "Tag Name"
    response :unauthorized
    response :ok
  end

  swagger_api :show do
    summary "Fetches a single tag"
    param :path, :id, :integer, :required, "id"
    response :ok, "Success", :tag
    response :unauthorized
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new tag"
    param :form, 'tag[name]', :string, :required, "Name"
    response :unauthorized
    response :created
    response :unprocessable_entity
  end

  swagger_api :update do
    summary "Updates an existing tag"
    param :path, :id, :integer, :required, "id"
    param :form, 'tag[name]', :string, :required, "Name"
    response :unauthorized
    response :ok
    response :not_found
  end

  swagger_api :destroy do
    summary "Deletes a tag"
    param :path, :id, :integer, :required, "id"
    response :unauthorized
    response :no_content
    response :not_found
  end

  def index
    if params[:name].blank?
      render :json => Tag.all, status: 200
    else
      render :json => Tag.where(:name => params[:name]), status: 200
    end
  end

  def show
    respond_with @tag
  end

  def create
    tag = Tag.new(tag_params)
    if tag.save
      render json: tag, status: 201
    else
      render json: { errors: tag.errors }, status: 422
    end
  end

  def update
    if @tag.update(tag_params)
      render json: @tag, status: 200
    else
      render json: { errors: @tag.errors }, status: 422
    end
  end

  def destroy
    @tag.destroy
    head 204
  end

  private
  def set_tag
    @tag = Tag.find(params[:id])
  end

  private
  def render_404_if_tag_unknown
    render json: { errors: 'Tag not found!' }, status: 404 unless
        Tag.exists?(params[:id])
  end

  private
  def tag_params
    params.fetch(:tag, {}).permit(:name)
  end
end