require 'cadre/rspec3'
require 'simplecov'
require 'simplecov-json'
require 'cadre/simplecov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::JSONFormatter,
  Cadre::SimpleCov::VimFormatter
]
SimpleCov.start

require 'codeclimate-test-reporter'
require 'webmock/rspec'
require 'pry'
require 'terminal-notifier-guard'

require 'bundler/setup'
Bundler.setup

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'relateiq'

WebMock.disable_net_connect!(allow: /codeclimate.com/)

CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.run_all_when_everything_filtered = true
  if config.formatters.empty?
    config.add_formatter(:progress)
    #but do consider:
    config.add_formatter(Cadre::RSpec3::TrueFeelingsFormatter)
  end
  config.add_formatter(Cadre::RSpec3::NotifyOnCompleteFormatter)
  config.add_formatter(Cadre::RSpec3::QuickfixFormatter)
end

RelateIq.configure do |config|
  config.base_url = 'https://test.relateiq.com'
  config.username = ''
  config.password = ''
end
