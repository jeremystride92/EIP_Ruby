# Disallow site indexing in non-production environments
Rails.application.config.middleware.insert_before(::Rack::Lock, '::Rack::Robots')
