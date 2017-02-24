class Api::V1::TagsController < BaseController

  before_action :authenticate_with_token!, :auth_by_admin_privilege!
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :tags, 'Tags'

  swagger_api :index do
    summary 'Returns all Tags'
    notes 'These are some notes for everybody!'
    param :query, :page, :integer, :optional, "Page number"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :show do
    summary "Fetches a single tag"
    param :path, :id, :integer, :required, "id"
    response :ok, "Success", :tag
    response :unauthorized
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new Tag"
    param :form, :name, :string, :required, "Name"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing tag"
    param :path, :id, :integer, :required, "id"
    param :form, :name, :string, :required, "Name"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes a tag"
    param :path, :id, :integer, :required, "id"
    response :unauthorized
    response :not_acceptable
  end

  def index
    respond_with Tag.all
  end

  def show
    respond_with Tag.find(params[:id])
  end

  def create
    tag = Tag.new(tag_params)
    if tag.save
      render json: tag, status: 201, location: [:api, tag]
    else
      render json: { errors: tag.errors }, status: 422
    end
  end

  def update
    tag = Tag.find(params[:id])

    if tag.update(tag_params)
      render json: tag, status: 200, location: [:api, tag]
    else
      render json: { errors: tag.errors }, status: 422
    end
  end

  def destroy
    tag = Tag.find(params[:id])
    tag.destroy
    head 204
  end

  private
  def tag_params
    params.permit(:name)
  end
end