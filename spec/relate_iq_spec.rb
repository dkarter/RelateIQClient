require 'spec_helper'

RSpec.describe RelateIq do
  let(:test_logger) { Logger.new(STDOUT) }

  before do
    RelateIq.configure do |config|
      config.base_url = 'https://itworks.relateiq.com'
      config.username = 'myusername'
      config.password = 'mypassword'
      config.logger = test_logger
    end
  end

  after do
    RelateIq.configure do |config|
      config.base_url = 'https://test.relateiq.com'
      config.username = ''
      config.password = ''
      config.logger = nil
    end
  end

  it 'exposes base_url in module configuration' do
    expect(RelateIq.configuration.base_url).to eq('https://itworks.relateiq.com')
  end

  it 'exposes username in module configuration' do
    expect(RelateIq.configuration.username).to eq('myusername')
  end

  it 'exposes password in module configuration' do
    expect(RelateIq.configuration.password).to eq('mypassword')
  end

  it 'exposes logger in module configuration' do
    expect(RelateIq.configuration.logger).to eq(test_logger)
  end

  it 'sets rest_client logger to configuration logger' do
    expect(RestClient.log).to eq(test_logger)
  end
end
