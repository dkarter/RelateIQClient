require 'spec_helper'

RSpec.describe RelateIq::ListItem do
  let(:lists_url) { 'https://test.relateiq.com/lists' }

  before do
    stub_request(:get, lists_url)
      .to_return(body: File.readlines('spec/fixtures/lists.json').join)

    stub_request(:get, "#{lists_url}/list2id/listitems/?contactIds=contactid")
      .to_return(body: File.readlines('spec/fixtures/list_items_by_contact_id.json').join)

    stub_request(:put, "#{lists_url}/list2id/listitems/listitemid")
      .to_return(body: File.readlines('spec/fixtures/list_item.json').join)

    stub_request(:post, "#{lists_url}/list2id/listitems")
      .to_return(body: File.readlines('spec/fixtures/list_item.json').join)
  end

  context '.create' do
    it 'requests correct url with all parameters' do
      RelateIq::ListItem.create(name: 'itemname', list_id: 'list2id')
      url = "#{lists_url}/list2id/listitems"
      expect(WebMock).to have_requested(:post, url)
        .with(body: '{"listId":"list2id","name":"itemname"}')
    end

    it 'returns the id of the list item' do
      item = RelateIq::ListItem.create(name: 'itemname', list_id: 'list2id')
      expect(item.id).to eq('listitemid')
    end
  end

  context '.find_by_contact' do
    let(:list_items) do
      RelateIq::ListItem.find_by_contact('list2id', 'contactid')
    end

    it 'requests correct url with all parameters' do
      RelateIq::ListItem.find_by_contact('list2id', 'contactid')
      expect(WebMock).to have_requested(:get, "#{lists_url}/list2id/listitems/?contactIds=contactid")
    end

    it 'returns 2 list items' do
      expect(list_items.count).to eq(2)
      expect(list_items[0].is_a? RelateIq::ListItem).to eq(true)
      expect(list_items[1].is_a? RelateIq::ListItem).to eq(true)
    end
  end

  context '.from_json' do
    it 'returns an instance of ListItem containing all properties specified in json' do
      json = '{ "listId": "list2id", "name": "test" }'
      deserialized_list_item = RelateIq::ListItem.from_json(json)
      expect(deserialized_list_item.list_id).to eq('list2id')
    end
  end

  context '#to_json' do
    it 'returns a full representation of list item in relateiq json format' do
      list_item = RelateIq::ListItem.new(
        name: 'itemname',
        list_id: 'list2id',
        field_values: [{ 'nobis' => 'Dancer' }],
        contact_ids: ['contactid1', 'contactid2'],
        account_id: 'accountid'
      )
      json_hash = {
        'listId' => 'list2id',
        'name' => 'itemname',
        'accountId' => 'accountid',
        'contactIds' => ['contactid1', 'contactid2'],
        'fieldValues' => {
          '0' => [{ 'raw' => '17' }]
        }
      }
      expect(list_item.to_json).to eq(json_hash.to_json)
    end

    it 'does not render an account id to a contact type list' do
      list_item = RelateIq::ListItem.new(
        list_id: 'list1id',
        contact_ids: ['contactid1', 'contactid2'],
        account_id: 'accountid'
      )
      json_hash = {
        'listId' => 'list1id',
        'contactIds' => ['contactid1', 'contactid2'],
      }
      expect(list_item.to_json).to eq(json_hash.to_json)
    end

    it 'omits properties that are not filled' do
      list_item = RelateIq::ListItem.new(
        name: 'itemname',
        list_id: 'list2id',
        field_values: [{ 'nobis' => 'Dancer' }]
      )
      json_hash = {
        'listId' => 'list2id',
        'name' => 'itemname',
        'fieldValues' => {
          '0' => [{ 'raw' => '17' }]
        }
      }
      expect(list_item.to_json).to eq(json_hash.to_json)
    end
  end

  context '#save' do
    it 'saves existing list item' do
      RelateIq::ListItem.new(
        id: 'listitemid',
        name: 'itemname',
        list_id: 'list2id',
        field_values: nil
      ).save
      url = "#{lists_url}/list2id/listitems/listitemid"
      expect(WebMock).to have_requested(:put, url)
        .with(body: '{"listId":"list2id","id":"listitemid","name":"itemname"}')
    end

    it 'creates new item when no id is supplied' do
      RelateIq::ListItem.new(
        name: 'itemname',
        list_id: 'list2id'
      ).save
      url = "#{lists_url}/list2id/listitems"
      expect(WebMock).to have_requested(:post, url)
        .with(body: '{"listId":"list2id","name":"itemname"}')
    end
  end
end
