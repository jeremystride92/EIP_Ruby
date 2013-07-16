if ENV['REDISTOGO_URL'].blank?
  $redis = Redis.new(host: 'localhost', port: 6379)
else
  uri = URI.parse(ENV['REDISTOGO_URL'])
  $redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
end
