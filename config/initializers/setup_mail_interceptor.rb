require 'mail_interceptor'
ActionMailer::Base.register_interceptor(MailInterceptor) if Rails.env.development?