source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'thin'
gem 'haml'
gem 'jquery-rails-cdn'
gem 'simple_form'
gem 'strong_parameters'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'rack-cors', require: 'rack/cors'
gem 'rabl-rails'

gem 'rails_autolink'
gem 'activerecord-import', '~> 0.3.1'

gem 'carrierwave'
gem 'mini_magick'
gem 'fog'

gem 'role_model'
gem 'cancan'

gem 'cocoon'

gem 'nexmo', '~> 1.1.0'

gem 'sidekiq'

gem 'bitly', '>= 0.9.0'

gem 'redis'

gem 'activeadmin'

gem 'unicorn'
gem 'foreman'
gem 'airbrake'

gem 'tinymce-rails'

gem 'rails_12factor', group: :production

gem 'httparty'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'less-rails'
  gem 'twitter-bootstrap-rails'

  gem 'sass-rails' # for active admin
  gem 'coffee-rails'

  gem 'ejs'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'
  #gem 'therubyracer', '0.12.1'

  gem 'uglifier', '>= 1.0.3'
end

group :production, :staging do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'quiet_assets'
end

group :development do
  gem 'haml-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'growl'
  gem 'rb-fsevent', '~> 0.9.1'
end

group :test do
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'rspec-sidekiq'
end
