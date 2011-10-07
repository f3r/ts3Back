class DeviseFakeMailer < ::ActionMailer::Base

  # MUST FIND A BETTER WAY TO DO THIS.

  def confirmation_instructions(record)
    # Disabling mailer
  end

  def reset_password_instructions(record)
    # Disabling mailer
  end

end