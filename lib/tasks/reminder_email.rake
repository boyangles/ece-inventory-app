desc 'send reminder email'
task send_reminder_email: :environment do
  # ... set options if any
  UserMailer.loan_reminder_emails_all.deliver_now
end