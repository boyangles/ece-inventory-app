source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

#Integration testing gem
gem 'rails-controller-testing'

# API Testing Swagger
gem 'swagger-docs'
gem 'ruby-swagger'

# Datepicker
gem 'bootstrap-datepicker-rails'

# Capybara RSpec Selenium Testing
gem 'capybara'
# gem 'rspec-rails'
%w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
  gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => 'master'
end

# Responds for respond_to
gem 'responders'
# Devise for authentication tokens
gem 'devise'

# DUKE OAUTH GEM for net id verification
gem "omniauth-duke-oauth2", :git => 'http://gitlab.oit.duke.edu/colab/omniauth-duke-oauth2.git', :ref => '5eaf6759'
gem "httparty"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
# Add bcrypt for password hashing
gem 'bcrypt', '3.1.11'
#Faker gem for dummy data TODO: ONLY use for dev environment
gem 'faker', '1.6.6'
#Paginations:
gem 'will_paginate', '3.1.0'
gem 'bootstrap-will_paginate', '0.0.10'
# Bootstrap sass gem
gem 'bootstrap-sass', '3.3.6'
gem 'jquery-turbolinks'
gem 'best_in_place'
gem 'bootstrap-x-editable-rails'
gem 'bootstrap-tagsinput-rails'
# React-Rails
gem 'react-rails'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby, group: [:production]

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Factory Girl Rails for testing suite for API
  gem "factory_girl_rails"
  # FFaker Gem for testing suite for API
  gem "ffaker"
  gem "shoulda-matchers"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
