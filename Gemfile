source 'https://rubygems.org'

gem 'rails', '~> 5.2'
gem 'dotenv-rails'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'nokogiri'
gem 'aws-sdk', '< 2.0' if ENV['storage'] == "s3"
gem 'rspec_api_documentation'
gem "apitome"
gem 'rails-html-sanitizer', ">= 1.0.4" # address CVE-2018-3741
gem 'jquery-tablesorter'
gem "sentry-raven"
gem 'devise'
gem "paperclip"
gem 'puma'
gem 'simple_form'
gem 'mysql2'

group :development do
  gem 'web-console', '~> 2.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'rails_layout'
  gem 'spring-commands-rspec'
end

group :development, :test do
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'poltergeist'
end

group :production do
  gem 'rails_12factor'
end
