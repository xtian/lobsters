# frozen_string_literal: true

if Rails.env.production?
  require 'exception_notification/rails'

  ExceptionNotification.configure do |config|
    # Ignore additional exception types.
    # ActiveRecord::RecordNotFound, Mongoid::Errors::DocumentNotFound,
    # AbstractController::ActionNotFound and ActionController::RoutingError are
    # already added.
    config.ignored_exceptions += %w[
      ActionController::ParameterMissing
      ActionController::UnknownFormat
      ActionController::BadRequest
      ActionDispatch::RemoteIp::IpSpoofAttackError
    ]

    config.add_notifier :slack,
                        backtrace_lines: 15,
                        webhook_url: Rails.application.secrets.slack_webhook_url
  end
end
