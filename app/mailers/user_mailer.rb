class UserMailer < ApplicationMailer
  default from: 'do-not-reply@3AndAHalfAsians.com'
  @url  = 'https://spicysoftware.colab.duke.edu'

  def welcome_email(user)
    @user = user
    @url  = 'https://spicysoftware.colab.duke.edu'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def request_initiated_email(requester, request, recipient)
    @user = requester
    @request = request
    @recipient = recipient
    email_params
    mail(to: @recipient.email, subject: @heading)
  end

  def request_initiated_email_all_subscribers(user, request)
    @subscribers = Subscriber.all
    UserMailer.request_initiated_email(user, request,user).deliver_now
    @subscribers.each do |recipient|
      puts recipient
      @tempRec = recipient.user
      UserMailer.request_initiated_email(user, request,@tempRec).deliver_now
      # request_replacement(recipient, shift).deliver
    end
  end

  def welcome_email_all
    @user = User.all
    @user.each do |recipient|
      puts recipient
      UserMailer.welcome_email(recipient).deliver_now
      # request_replacement(recipient, shift).deliver
    end
  end

  def request_approved_email(requester, request, recipient)
    @user = requester
    @request = request
    @recipient = recipient
    email_params
    mail(to: @recipient.email, subject: @heading)
  end

  def request_approved_email_all_subscribers(user, request)
    @subscribers = Subscriber.all
    UserMailer.request_approved_email(user, request,user).deliver_now
    @subscribers.each do |recipient|
      puts recipient
      @tempRec = recipient.user
      UserMailer.request_approved_email(user, request,@tempRec).deliver_now
      # request_replacement(recipient, shift).deliver
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

  # def loan_reminder_emails_all
  #   current_date = Time.now.strftime("%m/%d/%Y").to_s
  #   puts "START HERE"
  #   dates = Setting.email_dates
  #   dates = dates.split(",")
  #   dates.each do |date|
  #     if current_date == date.to_s
  #       allRequestItems = RequestItem.all
  #       requestItems = RequestItem.where("quantity_loan > ?", 0)
  #       requestItems.each do |loanItem|
  #         10.times do |i|
  #           puts "DATE"
  #           puts date
  #         end
  #         UserMailer.loan_reminder_email(loanItem).deliver_now
  #       end
  #     else
  #     end
  #   end
  # end

  def loan_reminder_emails_all

    allUsers = User.all

    current_date = Time.now.strftime("%m/%d/%Y").to_s
    10.times do |i|
      puts "START HERE"
    end
    dates = Setting.email_dates
    dates = dates.split(",")
    dates.each do |date|
      10.times do |i|
        puts "GOT HERE 1"
      end
      if current_date == date.to_s
        allUsers.each do |tempUser|
          @request_items = RequestItem.where("quantity_loan > ?", 0).where(request_id: Request.select(:id).where(user_id: tempUser, status: "approved"))
          puts "request items is this:"
          puts @request_items
          UserMailer.loan_reminder_email(@request_items, tempUser).deliver_now
        end
      else
      end
    end
  end


  private

  def email_params
    @heading = Setting.email_subject
    @body = Setting.email_body
    @url  = 'https://spicysoftware.colab.duke.edu'
  end

end