class Api::V1::TagsController < BaseController
  respond_to :json

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
    params.fetch(:tag, {}).permit(:name)
  end
end