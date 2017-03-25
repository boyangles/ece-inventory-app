class ApplicationMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack
  default from: 'what@gmail.com'
  layout 'mailer'
end

