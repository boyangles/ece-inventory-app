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
    @url  = 'https://spicysoftware.colab.duke.edu'
    @heading = Setting.email_heading
    @body = Setting.email_body
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
    @url  = 'https://spicysoftware.colab.duke.edu'
    @heading = Setting.email_heading
    @body = Setting.email_body
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

  #email types- loan initiate, loan approved, loan reminder-before, loan reminder-after, loan return
  def loan_email(user, request)
    @user = user
    @request = request
    @url  = 'https://spicysoftware.colab.duke.edu'
    @heading = Setting.email_heading
    @body = Setting.email_body
    mail(to: @user.email, subject: @heading)
  end

  def loan_reminder_emails

    puts "START HERE"
    allRequestItems = RequestItem.all

    requestItems = RequestItem.where("quantity_loan > ?", 0)
    requestItems.each do |item|
      puts "This is the item id"
      puts item.item.unique_name
      puts "This is quantity disbursed amount"
      puts item.quantity_disburse
      puts "This is quantity loaned amount"
      puts item.quantity_loan
      puts "This is the status"
      puts item.request.status
      puts "This is the item user"
      puts item.request.user.email
      @user = item.request.user.email
      puts "This is the item due date"
      puts item.created_at
      mail(to: @user.email, subject: @heading)
      # request_replacement(recipient, shift).deliver
    # @url  = 'https://spicysoftware.colab.duke.edu'
    @heading = Setting.email_heading
    @body = Setting.email_body
    end
  end
end