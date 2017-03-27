class Api::V1::SubscribersController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:index, :create, :destroy]
  before_action :render_404_if_subscriber_unknown, only: []
  before_action :set_subscriber, only: []

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :subscribers, 'Subscribers'

  swagger_api :index do
    summary "Shows users that are subscribed to the mailing list"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :create do
    summary "Signs yourself up to the mailing list"
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :destroy do
    summary "Unsubscribe yourself from the mailing list"
    response :no_content
    response :unprocessable_entity
  end

  def index
    render :json => Subscriber.all.map {
      |subscriber| {
          :subscription_id => subscriber.id,
          :user_id => subscriber.user_id,
          :username => User.find(subscriber.user_id).username,
          :email => User.find(subscriber.user_id).email
      }
    }, status: 200
  end

  def create
    @user = current_user_by_auth
    user_id = @user.id
    render_client_error("You are already subscribed!", 422) and
        return if Subscriber.exists?(:user_id => user_id)

    subscription = Subscriber.new(:user_id => user_id)
    if subscription.save
      render :json => {
          :subscription_id => subscription.id,
          :user_id => subscription.user_id,
          :username => @user.username,
          :email => @user.email
      }
    else
      render_client_error(subscription.errors, 422)
    end
  end

  def destroy
    Subscriber.find_by(:user_id => current_user_by_auth.id).destroy if
        Subscriber.exists?(:user_id => current_user_by_auth.id)
    head 204
  end

  ## Private Methods
  private
  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end

  private
  def render_404_if_subscriber_unknown
    render json: { errors: 'Subscriber not found!' }, status: 404 unless
        Subscriber.exists?(params[:id])
  end
end