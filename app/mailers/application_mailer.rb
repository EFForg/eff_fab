class ApplicationMailer < ActionMailer::Base
  default from: "fab@eff.org"
  layout 'mailer'

  def self.default_url_options
    Rails.application.config.action_controller.default_url_options || {}
  end
end
