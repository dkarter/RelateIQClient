require 'spec_helper'

RSpec.describe RelateIq::Contact do
  let(:contacts_url) { 'https://test.relateiq.com/contacts' }
  let(:email) { 'gulgowski.devyn@example.com' }
  let(:id) { 'contactid' }
  before do
    stub_request(:get, "#{contacts_url}/?properties.email=#{email}")
      .to_return(body: File.readlines('spec/fixtures/contacts_by_email.json').join)

    stub_request(:get, "#{contacts_url}/#{id}")
      .to_return(body: File.readlines('spec/fixtures/contact.json').join)

    stub_request(:post, "#{contacts_url}")
      .to_return(body: File.readlines('spec/fixtures/contact.json').join)

    stub_request(:put, "#{contacts_url}/#{id}")
      .to_return(body: File.readlines('spec/fixtures/contact.json').join)
  end

  context '.find_by_email' do
    it 'returns a Contact with a matching title' do
      contacts = RelateIq::Contact.find_by_email(email)
      expect(contacts[0].id).to eq(id)
    end

    it 'requests the correct url' do
      RelateIq::Contact.find_by_email(email)
      url = "#{contacts_url}/?properties.email=gulgowski.devyn@example.com"
      expect(WebMock).to have_requested(:get, url).once
    end
  end

  context '.find' do
    let(:contact) { RelateIq::Contact.find(id) }

    it 'requests the correct url' do
      RelateIq::Contact.find(id)
      url = "#{contacts_url}/#{id}"
      expect(WebMock).to have_requested(:get, url).once
    end

    it 'assigns relateiq properties to returned contact' do
      expect(contact.email).to eq(email)
    end
  end

  context '#initialize' do
    let(:contact_from_api) do
      RelateIq::Contact.new(
        id: 'someid',
        properties: {
          email: [{ value: 'hello@hello.com' }],
          company: [
            { value: 'Bolstr' },
            { value: 'Bolstr, Inc.' }
          ],
          liurl: [{ value: 'https://www.linkedin.com/in/doriankarter' }],
          twhan: [{ value: '@test' }]
        }
      )
    end

    let(:contact) do
      RelateIq::Contact.new(
        id: 'someid',
        email: 'hello@hello.com',
        first_name: 'Little',
        last_name: 'Wuckert',
        company: ['Bolstr', 'Bolstr, Inc.'],
        linkedin: 'https://www.linkedin.com/in/doriankarter'
      )
    end

    it 'can have mutltiple values on contact' do
      expect(contact_from_api.company).to eq(['Bolstr', 'Bolstr, Inc.'])
      expect(contact.company).to eq(['Bolstr', 'Bolstr, Inc.'])
    end

    it 'translates and cleans up relateiq keys' do
      expect(contact_from_api.linkedin).to eq('https://www.linkedin.com/in/doriankarter')
      expect(contact_from_api.twitter).to eq('@test')
      expect(contact_from_api).to_not respond_to(:liurl)
      expect(contact_from_api).to_not respond_to(:twhan)
    end

    it 'allows initializing by user' do
      expect(contact.id).to eq('someid')
      expect(contact.email).to eq('hello@hello.com')
      expect(contact.first_name).to eq('Little')
      expect(contact.last_name).to eq('Wuckert')
      expect(contact.linkedin).to eq('https://www.linkedin.com/in/doriankarter')
    end

    it 'assigns relateiq properties contact object' do
      expect(contact_from_api.email).to eq('hello@hello.com')
    end
  end

  context '#save' do
    let(:contact_to_update) do
      RelateIq::Contact.new(
        id: id,
        email: 'hello@hello.com',
        company: ['Bolstr', 'Bolstr, Inc.'],
        linkedin: 'https://www.linkedin.com/in/doriankarter'
      )
    end

    let(:contact_to_create) do
      RelateIq::Contact.new(
        email: 'hello@hello.com',
        company: ['Bolstr', 'Bolstr, Inc.'],
        linkedin: 'https://www.linkedin.com/in/doriankarter'
      )
    end

    it 'executes update when contact has no id' do
      contact_to_create.save
      url = "#{contacts_url}"
      expect(WebMock).to have_requested(:post, url).once
    end

    it 'executes create (post) when contact has id' do
      contact_to_update.save
      url = "#{contacts_url}/#{contact_to_update.id}"
      expect(WebMock).to have_requested(:put, url).once
    end
  end

  context '#to_json' do
    let(:contact) do
      RelateIq::Contact.new(
        id: 'someid',
        first_name: 'Little',
        last_name: 'Wuckert',
        email: 'hello@hello.com',
        company: ['Bolstr', 'Bolstr, Inc.'],
        linkedin: 'https://www.linkedin.com/in/doriankarter',
        twitter: '@test'
      )
    end

    it 'should return a proper relateiq json contact and not include unset attributes' do
      expected_json_hash = {
        id: 'someid',
        properties: {
          name: [{ value: 'Little Wuckert' }],
          email: [{ value: 'hello@hello.com' }],
          company: [
            { value: 'Bolstr' },
            { value: 'Bolstr, Inc.' }
          ],
          liurl: [{ value: 'https://www.linkedin.com/in/doriankarter' }],
          twhan: [{ value: '@test' }]
        }
      }
      expect(JSON.parse(contact.to_json, symbolize_names: true)).to eq(expected_json_hash)
    end
  end
end
