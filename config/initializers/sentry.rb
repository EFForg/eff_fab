Raven.configure do |config|
  # See https://docs.sentry.io/clients/ruby/integrations/rails/ for info

  # TODO: Sentry looks for `SENTRY_DSN`, so the only point of this
  # is to tell Figaro to serve the variable.
  # remove this once we migrate to dotenv.
  config.dsn = ENV['SENTRY_DSN']

  config.environments = %w(production)

  # It's possible to hide many headers and params from the Sentry logs.
  # See https://docs.sentry.io/clients/ruby/config/
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s) + %w(personal_emails api_token)
end

