Bitly.configure do |config|
  config.api_version = 3
  config.login = ENV['bitly_user']
  config.api_key = ENV['bitly_api_key']
end
