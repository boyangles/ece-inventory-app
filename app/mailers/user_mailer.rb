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

  def loan_convert_email(requestItem)
    @user = User.all
    # @request = request
    @url  = 'https://spicysoftware.colab.duke.edu'
    @heading = Setting.email_heading
    @body = Setting.email_body
    mail(to: @user.email, subject: @heading)
  end

  def loan_reminder_emails

    current_date = Time.now.strftime("%m/%d/%Y").to_s

    puts "START HERE"

    dates = Setting.email_dates

    puts "DATES"
    puts "DATES"
    puts "DATES"
    puts "DATES"
    puts "DATES"
    dates = dates.split(",")
    puts dates
    puts dates

    dates.each do |date|
      if current_date == date.to_s
        allRequestItems = RequestItem.all
        requestItems = RequestItem.where("quantity_loan > ?", 0)
        # requestItems = requestItems.where(request: 'outstanding')
        requestItems.each do |item|
          # puts "Here are the dates!!!"
          # puts date
          # puts "Here are the dates!!!"
          # puts date
          # puts "Here are the dates!!!"
          # puts date
          # puts "Here are the dates!!!"
          # puts date
          # puts "Here are the dates!!!"
          # puts date
          # puts "Here are the dates!!!"
          # puts date
          # puts "Here are the dates!!!"
          # puts date
          @user = item.request.user
          @requestItem = item
          mail(to: @user.email, subject: @heading)
          # puts "Sent email!!!"
          # puts "Sent email!!!"
          # puts "Sent email!!!"
          # request_replacement(recipient, shift).deliver
          # @url  = 'https://spicysoftware.colab.duke.edu'
          @heading = Setting.email_heading
          @body = Setting.email_body
        end
      else
        puts "the date is the not the same"
        puts date
        puts current_date
        puts "The dates were listed above"
      end
    end
  end
end