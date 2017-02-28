class LogsController < ApplicationController

  # TODO: no conscious log creation errr outside acquisition/destruction.
  before_action :check_logged_in_user

  def index

    if params[:user_search].blank? && params[:item_search].blank? && params[:start_date].blank? && params[:end_date].blank?
      @logs = Log.all.paginate(page: params[:page], per_page: 10)
    else
      userLogs = Log.where(user_id: User.select(:id).where("username ILIKE ?", "%#{params[:user_search]}%"))
      userInReqLogs = Log.where(id: RequestLog.select(:log_id).where(request_id: Request.select(:id).where(user_id: User.select(:id).where("username ILIKE ?", "%#{"trev"}%"))))
      users = Log.where(id: UserLog.select(:log_id).where(user_id: User.select(:id).where("username ILIKE ?", "%#{params[:user_search]}%")))
      itemLogs = Log.where(id: ItemLog.select(:log_id).where(item_id: Item.select(:id).where("unique_name ILIKE ?", "%#{params[:item_search]}%")))
      itemInReqLogs = Log.where(id: RequestLog.select(:log_id).where(request_id: RequestItem.select(:request_id).where(item_id: Item.select(:id).where("unique_name ILIKE ?", "%#{params[:item_search]}%"))))
      startLogs = Log.where("created_at >= :date", date: params[:start_date])
      endLogs = Log.where("created_at <= :date", date: params[:end_date])
      betweenDatesLogs = Log.where(created_at: params[:start_date]..params[:end_date])

      if !params[:user_search].blank?
        firstLayer = Log.where(id: userLogs | users | userInReqLogs)
      end

      if !params[:item_search].blank? && !firstLayer.blank?
        secondLayer = Log.where(id: firstLayer & (itemLogs | itemInReqLogs))
      elsif !params[:item_search].blank?
        secondLayer = (itemLogs | itemInReqLogs)
      else
        secondLayer = firstLayer
      end

      if !params[:start_date].blank? && !secondLayer.blank?
        thirdLayer = Log.where(id: secondLayer & startLogs)
      elsif !params[:start_date].blank?
        thirdLayer = startLogs
      else
        thirdLayer = secondLayer
      end

      if !params[:end_date].blank? && !thirdLayer.blank?
        fourthLayer = Log.where(id: thirdLayer & endLogs)
      elsif !params[:end_date].blank?
        fourthLayer = endLogs
      else
        fourthLayer = thirdLayer
      end

      @logs = Log.where(id: fourthLayer).paginate(page: params[:page], per_page: 10)
    end

  end

  def new
    @log = Log.new
  end

  def create
    @log = Log.new(log_params)
    # @log.item_id = params[:item][:id]
    # @item = @log.item

    #if !@item
    #  reject_to_new("Item does not exist") and return
    #elsif Log.oversubscribed?(@item, @log)
    #  reject_to_new("Oversubscribed!") and return
    #else
    save_form(@log)
    #  @item.update_by_subrequest(@log, @log.request_type)
    #  @item.save!
    #end
  end

  private
  def log_params
    params.fetch(:log, {}).permit(:user_id, :log_type)
  end

  def save_form(log)
    if log.save
      flash[:success] = "Log successfully saved!"
      redirect_to(logs_path)
    else
      flash.now[:danger] = "Log could not be successfully saved"
      render 'new'
    end
  end

  def reject_to_new(msg)
    flash.now[:danger] = msg
    render 'new'
  end
end
