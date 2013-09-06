Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
  config.rescue_rake_exceptions = true
  config.development_environments << %w(staging)
end
