source 'https://rubygems.org'

# ruby '2.2.1'

gem 'active_rest_client'
gem 'rest-client'

group :development, :test do
  gem 'rspec', '~> 3.1.0'
  gem 'rspec_junit_formatter'
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'plymouth'
  gem 'zenflow'
  gem 'rubocop'
end

group :test do
  # code coverage
  gem 'simplecov', require: false
  gem 'simplecov-json', require: false

  # Guard stuff
  gem 'guard'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'

  # CodeClimate
  gem 'codeclimate-test-reporter', require: nil

  # Mocking and stubbing
  gem 'webmock'
end
