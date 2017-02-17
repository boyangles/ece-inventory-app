class Api::V1::UsersController < ApplicationController
  # TODO: Include actions for #create
  before_action :authenticate_with_token!, only: [:index, :show, :update, :destroy]
  before_action :auth_by_admin_privilege!, only: [:index]
  before_action -> { auth_by_same_user_or_admin!(params[:id]) }, only: [:show, :update, :destroy]

  respond_to :json

  def index
    respond_with User.all
  end

  def show
    respond_with User.find(params[:id])
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: 201, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def update
    user = User.find(params[:id])

    if user.update(user_params)
      render json: user, status: 200, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    head 204
  end

  private
    def user_params
      params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation, :privilege)
    end
end
