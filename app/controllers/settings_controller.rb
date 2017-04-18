class SettingsController < ApplicationController

  before_action :check_logged_in_user
  before_action :check_manager_or_admin

  before_action :get_setting, only: [:edit, :update]

  def index
    @settings = Setting.get_all
  end

  def edit
    puts "Param is here: #{params[:id]}"
    puts "Setting is here: #{Setting.all}"
  end

  def dates
    @setting = Setting.find_by(var: 'email_dates') || Setting.new(var: 'email_dates')

    @temp_date = @setting
    # binding.pry
  end

  def create
    puts "Setting email dates here"
    puts Setting.email_dates
    redirect_to settings_path
  end

  def update_dates
    @setting = Setting.find_by(var: 'email_dates') || Setting.new(var: 'email_dates')
    if @setting.value != params[:start_date]
      @setting.value = params[:start_date]
      @setting.save
      redirect_to settings_path, notice: 'Settings have been updated.'
    else
      redirect_to settings_path
    end
  end

  def update
    if @setting.value != params[:setting][:value]
      @setting.value = params[:setting][:value]
      @setting.save
      redirect_to settings_path, notice: 'Settings have been updated.'
    else
      redirect_to settings_path
    end
  end

  def get_setting
    @setting = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id])
  end
end