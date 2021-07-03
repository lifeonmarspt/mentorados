if Rails.env.test? == false
  Rails.application.config.action_mailer.delivery_method = :ses
end

# TODO Think of a better way to set this up. Either have a local instance of ses, or some other mail service
# Avoids having to configure SES stuff in development
if Rails.env.development?
  Rails.application.config.action_mailer.delivery_method = :test
end

Rails.application.config.action_mailer.default_url_options = { host: ENV.fetch("BASE_URL") }
