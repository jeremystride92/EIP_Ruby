require 'sidekiq'

# Calculated using http://manuel.manuelles.nl/sidekiq-heroku-redis-calc/
# Nano (10 connection) instance
# 2 web dynos
# 3 Unicorns per dyno
# 1 redis connection needed per client
# 1 worker dyno for sidekiq
# (so 6 connections are used by web dynos, leaving 4 for the Sidekiq server)

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :size => 4 }
end
