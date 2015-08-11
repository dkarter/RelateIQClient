require 'spec_helper'

RSpec.describe 'Update a list item for a contact' do
  let(:accounts_url) { 'https://test.relateiq.com/accounts' }
  let(:contacts_url) { 'https://test.relateiq.com/contacts' }
  let(:lists_url) { 'https://test.relateiq.com/lists' }
  let(:email) { 'gulgowski.devyn@example.com' }

  before do
    stub_request(:get, lists_url)
      .to_return(body: File.readlines('spec/fixtures/lists.json').join)

    stub_request(:get, "#{lists_url}/list2id/listitems/?contactIds=contactid")
      .to_return(body: File.readlines('spec/fixtures/list_items_by_contact_id.json').join)

    stub_request(:post, "#{lists_url}/list2id/listitems")
      .to_return(body: File.readlines('spec/fixtures/list_item.json').join)

    stub_request(:post, "#{accounts_url}")
      .to_return(body: File.readlines('spec/fixtures/account_by_id.json').join)

    stub_request(:get, "#{contacts_url}/?properties.email=#{email}")
      .to_return(body: File.readlines('spec/fixtures/contacts_by_email.json').join)

    stub_request(:put, "#{lists_url}/list2id/listitems/listitem1")
      .to_return(body: File.readlines('spec/fixtures/list_item.json').join)

    stub_request(:put, "#{lists_url}/list2id/listitems/listitem2")
      .to_return(body: File.readlines('spec/fixtures/list_item.json').join)
  end

  it 'finds list by name, creates an account and creates a list item for that list and account' do
    list = RelateIq::List.find_by_title('Burundi')
    account = RelateIq::Account.create(name: 'Simple Company')
    list_item = list.upsert_item(
      name: 'Simple Name',
      account_id: account.id,
      field_values: [
        { 'sint' => 'Administrator, Civil Service' },
        { 'status' => 'Homeopath' },
        { 'maiores' => 'test123' }
      ]
    )

    expect(list_item.id).to eq('listitemid')
    expect(list_item.account_id).to eq('accountid')
  end

  it 'can find a list items by contact id and update their status' do
    contacts = RelateIq::Contact.find_by_email(email)
    list = RelateIq::List.find_by_title('Burundi')
    contacts.each do |contact|
      list_items = list.items_by_contact_id(contact.id)
      list_items.each do |list_item|
        list_item.field_values << { 'status' => 'Homeopath' }
        list_item.save
      end
    end

    expect(WebMock).to have_requested(:put, "#{lists_url}/list2id/listitems/listitem1")
      .with(body: '{"listId":"list2id","id":"listitem1","name":"hello+test@example.com",' \
                  '"contactIds":["contactid"],"fieldValues":{"0":[{"raw":"3"}],"44":[' \
                  '{"raw":"3"}]}}')
    expect(WebMock).to have_requested(:put, "#{lists_url}/list2id/listitems/listitem2")
      .with(body: '{"listId":"list2id","id":"listitem2","name":"hello@example.com",' \
                  '"contactIds":["contactid"],"fieldValues":{"0":[{"raw":"2"}],"' \
                  '44":[{"raw":"3"}]}}')
  end
end
