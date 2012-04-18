class BaseMailer < ActionMailer::Base
  add_template_helper(FrontendHelper)
  layout 'user_email'

  default :from => MAILER_SENDER
  default :bcc  => ["jeremy@squarestays.com", "fer@squarestays.com"].join(',')
end