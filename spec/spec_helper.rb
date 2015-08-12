require 'simplecov'
require 'simplecov-json'
SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
SimpleCov.start

require 'codeclimate-test-reporter'
require 'webmock/rspec'
require 'pry'
require 'terminal-notifier-guard'

require 'bundler/setup'
Bundler.setup

$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib', 'relateiq')

require 'relateiq'

WebMock.disable_net_connect!(allow: /codeclimate.com/)

CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

RelateIq.configure do |config|
  config.base_url = 'https://test.relateiq.com'
  config.username = ''
  config.password = ''
end
