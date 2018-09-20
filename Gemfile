# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.1'

gem 'rails', '~> 5.2.0'

gem 'pg'
gem 'pg_search'

# rails
gem 'activerecord-typedstore'
gem 'scenic'

# js
gem 'dynamic_form'
gem 'jquery-rails', '~> 4.3'
gem 'json'
gem 'uglifier', '>= 1.3.0'

# deployment
gem 'actionpack-page_caching'
gem 'puma'

# security
gem 'bcrypt', '~> 3.1.2'
gem 'rotp'
gem 'rqrcode'

# parsing
gem 'commonmarker', '~> 0.14'
gem 'htmlentities'
gem 'nokogiri', '>= 1.7.2'

gem 'mail' # for parsing incoming mail
gem 'oauth' # for twitter-posting bot
gem 'sitemap_generator' # for better search engine indexing

group :test, :development do
  gem 'bullet'
  gem 'byebug'
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'listen'
  gem 'rb-readline'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'sqlite3'
end

group :test do
  gem 'fuubar' # RSpec progress bar formatter
  gem 'webmock' # Mocks external requests
end

group :production do
  gem 'exception_notification' # Sends notifications when errors occur
  gem 'puma-heroku' # Default Puma configuration
end
