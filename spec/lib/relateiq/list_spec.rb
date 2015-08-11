require 'spec_helper'

RSpec.describe RelateIq::List do
  let(:lists_url) { 'https://test.relateiq.com/lists' }
  let(:list_class) { RelateIq::List }
  let(:list_2) { RelateIq::List.find_by_title('Burundi') }
  let(:list_hash) do
    {
      id: 'someid',
      title: 'List Title',
      listType: 'contact',
      modifiedDate: 12345678,
      fields: [
        {
          id: '5',
          name: 'unde',
          listOptions: [],
          isMultiSelect: false,
          isEditable: false,
          dataType: 'DateTime'
        },
        {
          id: '9',
          name: 'porro',
          listOptions: [
            {
              id: '0',
              display: 'Teacher, special educational needs'
            },
            {
              id: '1',
              display: 'Applications developer'
            }
          ],
          isMultiSelect: false,
          isEditable: true,
          dataType: 'List'
        }
      ]
    }
  end
  let(:list_json) { list_hash.to_json }

  before do
    stub_request(:get, lists_url)
      .to_return(body: File.readlines('spec/fixtures/lists.json').join)

    stub_request(:get, "#{lists_url}/list2id/listitems/?contactIds=contactid")
      .to_return(body: File.readlines('spec/fixtures/list_items_by_contact_id.json').join)
  end

  context '.all' do
    it 'returns an array of lists' do
      expect(list_class.all.count).to eq(6)
      list_class.all.each do |item|
        expect(item.is_a? list_class).to eq(true)
      end
    end

    it 'returns field list_options as an array' do
      status_field = RelateIq::List.all[0].fields.find { |f| f[:name] == 'status' }
      status_field[:listOptions].is_a? Array
    end

    it 'caches a copy in memory and does not call web method more than once' do
      list_class.clean_cache
      list_class.all
      list_class.all
      expect(WebMock).to have_requested(:get, lists_url).once
    end
  end

  context '.find_by_title' do
    it 'returns a List with a matching title' do
      expect(list_class.find_by_title('Swaziland')).to eq(list_class.all[2])
    end

    it 'is case insensitive' do
      expect(list_class.find_by_title('swaziland')).to eq(list_class.all[2])
    end
  end

  context '.from_json' do
    it 'can create an array of lists from json' do
      lists_from_json = RelateIq::List.from_json(File.readlines('spec/fixtures/lists.json').join)
      lists_from_json.each do |l|
        expect(l.is_a?(RelateIq::List)).to eq(true)
      end
      expect(lists_from_json.count).to eq(6)
    end

    it 'can create a single list from json' do
      list_from_json = RelateIq::List.from_json(list_json)
      expect(list_from_json.id).to eq('someid')
    end
  end

  context '#initialize' do
    let(:list_from_api) do
      RelateIq::List.new(list_hash)
    end

    let(:list) do
      RelateIq::List.new(
        id: 'someid',
        title: 'List Title',
        list_type: 'contact'
      )
    end

    it 'translates and cleans up relateiq keys' do
      expect(list_from_api.list_type).to eq('contact')
      expect(list_from_api.modified_date).to eq(12345678)
    end

    it 'allows setting attributes directly through the constructor' do
      expect(list.list_type).to eq('contact')
    end
  end

  context '#items_by_contact_id' do
    it 'can accept a single contact id' do
      list_item_class = RelateIq::ListItem
      allow(list_item_class).to receive(:find_by_contact)
      list_2.items_by_contact_id('contactid')
      expect(list_item_class).to have_received(:find_by_contact).with('list2id', 'contactid')
    end
  end

  context '#upsert_item' do
    before do
      stub_request(:put, "#{lists_url}/list2id/listitems/listitemid")
        .to_return(body: File.readlines('spec/fixtures/list_item.json').join)

      stub_request(:post, "#{lists_url}/list2id/listitems")
        .to_return(body: File.readlines('spec/fixtures/list_item.json').join)
    end

    it 'creates a post request if no id is provided includes current list id' do
      list_2.upsert_item(name: 'test')
      expect(WebMock).to have_requested(:post, "#{lists_url}/list2id/listitems")
        .with(body: '{"listId":"list2id","name":"test"}')
    end
  end
end
