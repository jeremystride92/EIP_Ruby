require 'rack'

# Disallow site indexing in non-production environments
module Rack
  class Robots
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'] == '/robots.txt' && !([ENV['RAILS_ENV'], ENV['RACK_ENV']].include? 'production')
        [200, { 'Content-Type' => 'text/plain' }, ["User-Agent: *\nDisallow: /"]]
      else
        @app.call env
      end
    end
  end
end
