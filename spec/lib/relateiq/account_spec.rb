require 'spec_helper'

RSpec.describe RelateIq::Account do
  let(:account) { RelateIq::Account.new(id: 'accountid', name: 'account_name') }
  let(:accounts_url) { 'https://test.relateiq.com/accounts' }
  let(:json) { '{ "id": "accountid", "name": "account_name" }' }

  before do
    stub_request(:get, "#{accounts_url}/accountid")
      .to_return(body: File.readlines('spec/fixtures/account_by_id.json').join)
    stub_request(:put, "#{accounts_url}/accountid")
      .to_return(body: File.readlines('spec/fixtures/account_by_id.json').join)
    stub_request(:post, "#{accounts_url}")
      .to_return(body: File.readlines('spec/fixtures/account_by_id.json').join)
  end

  context '#initiazlie' do
    it 'sets account id and name from initializer' do
      expect(account.id).to eq('accountid')
      expect(account.name).to eq('account_name')
    end
  end

  context '#to_json' do
    it 'returns a properly serialized account' do
      expect(JSON.parse(account.to_json)).to eq(JSON.parse(json))
    end
  end

  context '#save' do
    it 'calls correct save url with account serialized to JSON' do
      RelateIq::Account.new(id: 'accountid', name: 'Testing Account').save
      expect(WebMock).to have_requested(:put, "#{accounts_url}/accountid")
        .with(body: '{"name":"Testing Account","id":"accountid"}')
    end
  end

  context '.find' do
    it 'returns a single account by id' do
      account = RelateIq::Account.find('accountid')
      expect(account.id).to eq('accountid')
      expect(account.name).to eq('Bolstr, Inc.')
    end
  end

  context '.from_json' do
    it 'returns an account object from json representation' do
      account_from_json = RelateIq::Account.from_json(json)
      expect(account_from_json.id).to eq('accountid')
      expect(account_from_json.name).to eq('account_name')
    end
  end

  context '.create' do
    it 'creates an account and returns its id' do
      account = RelateIq::Account.create(name: 'Testing Account')
      expect(account.id).to eq('accountid')
    end

    it 'calls the correct url with body params' do
      RelateIq::Account.create(name: 'Testing Account')
      expect(WebMock).to have_requested(:post, accounts_url)
        .with(body: '{"name":"Testing Account"}').once
    end
  end
end
