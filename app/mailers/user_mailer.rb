class UserMailer < ApplicationMailer
  default from: 'do-not-reply@3AndAHalfAsians.com'

  # def welcome_email(user)
  #   @user = user
  #   @url  = 'https://spicysoftware.colab.duke.edu'
  #   mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  # end

  # def welcome_email_all
  #   @user = User.all
  #   @user.each do |recipient|
  #     UserMailer.welcome_email(recipient).deliver_now
  #   end
  # end

  def request_initiated_email(requester, request, recipient)
    request_params(requester, request, recipient)
    email_params
    mail(to: @recipient.email, subject: @heading)
  end

  def request_initiated_email_all_subscribers(user, request)
    @subscribers = Subscriber.all
    UserMailer.request_initiated_email(user, request,user).deliver_now
    @subscribers.each do |recipient|
      @tempRec = recipient.user
      UserMailer.request_initiated_email(user, request,@tempRec).deliver_now
    end
  end


  def request_approved_email(reqOperator, request, recipient,userMadeRequest)
    request_params(reqOperator, request, recipient)
    @userMadeRequest = userMadeRequest
    email_params
    mail(to: @recipient.email, subject: @heading)
  end

  def request_approved_email_all_subscribers(reqApprover, request, userMadeRequest)
    @subscribers = Subscriber.all
    UserMailer.request_approved_email(reqApprover, request, request.user, userMadeRequest).deliver_now
    @subscribers.each do |recipient|
      @tempRec = recipient.user
      UserMailer.request_approved_email(reqApprover, request,@tempRec,userMadeRequest).deliver_now
    end
  end

  def request_denied_email(reqDenier, request, recipient)
    request_params(reqDenier, request, recipient)
    email_params
    mail(to: @recipient.email, subject: @heading)
  end

  def request_denied_email_all_subscribers(reqDenier, request)
    @subscribers = Subscriber.all
    UserMailer.request_denied_email(reqDenier, request,request.user).deliver_now
    @subscribers.each do |recipient|
      @tempRec = recipient.user
      UserMailer.request_denied_email(reqDenier, request,@tempRec).deliver_now
    end
  end

  # def request_destroyed_email(reqDestroyer, request, recipient)
  #   request_params(reqDestroyer, request, recipient)
  #   email_params
  #   mail(to: @recipient.email, subject: @heading)
  # end
  #
  # def request_destroyed_email_all_subscribers(reqDestroyer, request)
  #   @subscribers = Subscriber.all
  #   UserMailer.request_denied_email(reqDestroyer, request,request.user).deliver_now
  #   @subscribers.each do |recipient|
  #     @tempRec = recipient.user
  #     UserMailer.request_destroyed_email(reqDestroyer, request,@tempRec).deliver_now
  #   end
  # end

  def loan_convert_email(requestItem)
    loan_email_template(requestItem, requestItem.request.user)
  end

  def loan_return_email(requestItem)
    loan_email_template(requestItem, requestItem.request.user)
  end

  def loan_reminder_email(loanItem, tempUser)
    loan_email_template(loanItem, tempUser)
  end


  def loan_reminder_emails_all
    allUsers = User.all

    current_date = Time.now.strftime("%m/%d/%Y").to_s
    dates = Setting.email_dates.gsub(/\s+/, "")
    dates = dates.split(",")
    dates.each do |date|
      if current_date == date.to_s
        allUsers.each do |tempUser|
          @request_items = RequestItem.where("quantity_loan > ?", 0).where(request_id: Request.select(:id).where(user_id: tempUser, status: "approved"))
          if !@request_items.blank?
            UserMailer.loan_reminder_email(@request_items, tempUser).deliver_now
          end
        end
      end
    end
  end

  private

  def loan_email_template(reqItem, user)
    @user = user
    @request_items = reqItem
    email_params
    mail(to: @user.email, subject: @heading)
  end

  def request_params(reqOperator, request, recipient)
    @user = reqOperator
    @request = request
    @recipient = recipient
  end

  def email_params
    @heading = Setting.email_subject
    @body = Setting.email_body
    @url  = 'https://spicysoftware.colab.duke.edu'
  end

end