class RegistrationMailer < Devise::Mailer
  add_template_helper(FrontendHelper)
  layout 'user_email'

  default :from => SiteConfig.mailer_sender
  default :bcc  => SiteConfig.mail_bcc
end