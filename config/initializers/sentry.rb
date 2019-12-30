Raven.configure do |config|
  config.dsn = 'https://e34ae4b0b3d94181828cec6feca3f6fd:f1f8fdac45ac46fea594b2d6a57b18e0@sentry.io/1401702'
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w[production]
  config.excluded_exceptions += [
    Pundit::NotAuthorizedError
  ]
end
