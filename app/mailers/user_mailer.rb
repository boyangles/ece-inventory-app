class UserMailer < ApplicationMailer
  default from: 'do-not-reply@3AndAHalfAsians.com'
  @url  = 'https://spicysoftware.colab.duke.edu'

  def welcome_email(user)
    @user = user
    @url  = 'https://spicysoftware.colab.duke.edu'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

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

  # def welcome_email_all
  #   @user = User.all
  #   @user.each do |recipient|
  #     UserMailer.welcome_email(recipient).deliver_now
  #   end
  # end

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


  def loan_convert_email(requestItem)
    @user = requestItem.request.user
    @request_items  = requestItem
    email_params
    mail(to: @user.email, subject: @heading)
  end

  def loan_return_email(requestItem)
    @user = requestItem.request.user
    @request_items  = requestItem
    email_params
    mail(to: @user.email, subject: @heading)
  end

  def loan_reminder_email(loanItem, tempUser)
    @user = tempUser
    @request_items = loanItem
    email_params
    mail(to: @user.email, subject: @heading)
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