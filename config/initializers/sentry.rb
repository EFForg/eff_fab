Raven.configure do |config|
  # See https://docs.sentry.io/clients/ruby/integrations/rails/ for info

  config.environments = %w(production)

  # It's possible to hide many headers and params from the Sentry logs.
  # See https://docs.sentry.io/clients/ruby/config/
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s) + %w(personal_emails api_token)
end

