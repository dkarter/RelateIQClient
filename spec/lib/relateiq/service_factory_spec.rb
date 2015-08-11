require 'spec_helper'

RSpec.describe RelateIq::ServiceFactory do
  it 'connects to an endpoint by name' do
    endpoint = RelateIq::ServiceFactory.get_endpoint('lists')
    expect(endpoint).to respond_to(:get)
  end
end
