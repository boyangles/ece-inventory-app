class Api::V1::SettingsController < BaseController
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:index, :modify_email_subject, :modify_email_body, :modify_email_dates]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:modify_email_subject, :modify_email_body, :modify_email_dates].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :settings, 'Settings'

  swagger_api :index do
    summary "Views all settings related to loan reminder emails"
    notes 'Lists email heading, email body and email dates settings'
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :modify_email_subject do
    summary "Modify Email Heading"
    notes 'Configure the subject tag to be prepended in the subject line of reminder emails'
    param :query, :email_subject, :string, :required, 'Subject Tag'
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :modify_email_body do
    summary "Modify Email Body"
    notes 'Configure a body of text to be prepended in the body of reminder emails'
    param :query, :email_body, :string, :required, 'Email Body'
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :modify_email_dates do
    summary "Modify Email Dates"
    notes 'Configure on which dates loan reminder emails are sent'
    param :query, :email_dates, :string, :required, 'Comma deliminated list of dates in mm/dd/yyyy format, e.g. ["04/15/1995", "06/07/1995"]'
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  def index
    render :json => Setting.get_all, status: 200
  end

  def modify_email_subject
    @setting = Setting.find_by(var: 'email_subject') || Setting.new(var: 'email_subject')
    @setting.value = params[:email_subject]

    if @setting.save
      render :json => Setting.get_all, status: 200
    else
      render_client_error("Email Heading could not be saved!", 422)
    end
  end

  def modify_email_body
    @setting = Setting.find_by(var: 'email_body') || Setting.new(var: 'email_body')
    @setting.value = params[:email_body]

    if @setting.save
      render :json => Setting.get_all, status: 200
    else
      render_client_error("Email Body could not be saved!", 422)
    end
  end

  def modify_email_dates
    @setting = Setting.find_by(var: 'email_dates') || Setting.new(var: 'email_dates')
    render_client_error("Invalid Format", 422) and return unless valid_json?(params[:email_dates])
    email_dates = JSON.parse(params[:email_dates])
    render_client_error("JSON format must be array", 422) and return unless email_dates.kind_of?(Array)

    email_dates.each do |date|
      render_client_error("JSON array must consist of all Strings. #{date} -- is not an actual String.", 422) and return unless date.kind_of?(String)
      month, day, year = date.split('/')
      render_client_error("Must be a valid date! #{date} is not a valid date.", 422) and return unless Date.valid_date?(year.to_i, month.to_i, day.to_i)
    end

    @setting.value = email_dates.join(',')

    if @setting.save
      render :json => Setting.get_all, status: 200
    else
      render_client_error("Email Dates could not be saved!", 422)
    end
  end
end