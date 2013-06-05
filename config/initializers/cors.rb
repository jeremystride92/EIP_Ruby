# CORS - Cross origin resource sharing
# See https://github.com/cyu/rack-cors

Rails.application.config.middleware.use Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', headers: :any, methods: [:get, :post, :delete, :put, :options]
  end
end
