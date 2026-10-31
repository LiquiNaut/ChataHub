class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "ChataHub <noreply@chatahub.test>")
  layout "mailer"
end
