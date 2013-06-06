CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['s3_key'],
    :aws_secret_access_key  => ENV['s3_secret']
  }
  config.fog_directory  = ENV['s3_bucket']
  config.fog_public     = true
  config.asset_host     = "//#{ENV['s3_bucket']}.#{ENV['s3_asset_domain']}"
  config.permissions    = 0666

  # Needed for Heroku
  config.root = File.dirname(__FILE__) + '/tmp'
  config.cache_dir = 'carrierwave'

  if Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  else
    config.storage = :fog
    config.enable_processing = true
  end
end
