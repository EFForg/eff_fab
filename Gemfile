source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.10'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer'
gem 'execjs'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'nokogiri'
gem 'aws-sdk', '< 2.0' if ENV['storage'] == "s3"

group :development, :test do
  gem 'byebug'
end
group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
end
gem 'devise'
gem 'figaro'
gem "paperclip"
gem 'puma'
gem 'simple_form'
group :development do
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring-commands-rspec'
end
group :development, :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rspec-rails'
  gem 'sqlite3'
end

group :production do
  gem 'rails_12factor'

  # Include database gems for the adapters found in the database
  # configuration settings key for production
  require 'erb'
  require 'yaml'
  application_file = File.join(File.dirname(__FILE__), "config/application.yml")
  if File.exist?(application_file)
    application_config = YAML::load(ERB.new(IO.read(application_file)).result)
    db_adapter = application_config['production']['db_adapter']
    if db_adapter == "mysql2"
      gem 'mysql2'
    elsif db_adapter == "postgresql"
      gem 'pg'
    else
      warn("No adapter found in config/application.yml, please configure it first")
    end
  else
    warn("Please configure your config/application.yml first")
  end
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'poltergeist'
end
