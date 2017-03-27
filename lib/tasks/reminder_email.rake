desc 'send reminder email'
task send_reminder_email: :environment do
  # ... set options if any
  # current_date = Time.now.strftime("%Y-%m-%d").to_s
  # puts current_date
  UserMailer.loan_reminder_emails_all.deliver_now
end