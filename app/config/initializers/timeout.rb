# Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 500
# Rack::Timeout.unregister_state_change_observer(:logger) if Rails.env.development?
# Rack::Timeout.timeout = ENV.fetch('REQUEST_TIMEOUT') { 5 }.to_i
