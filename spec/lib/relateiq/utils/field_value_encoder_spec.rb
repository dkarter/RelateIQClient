require 'spec_helper'

RSpec.describe RelateIq::Utils::FieldValueEncoder do
  let(:list_options) do
    [
      { id: '9', display: 'loval 1' },
      { id: '10', display: 'loval 2' }
    ]
  end
  let(:fields) do
    [
      { id: '7', name: 'notmyfield', listOptions: [] },
      { id: '5', name: 'myfield', listOptions: [] },
      { id: '6', name: 'listfield', listOptions: list_options }
    ]
  end
  let(:list) { double('List', fields: fields) }
  let(:encoder) { RelateIq::Utils::FieldValueEncoder.new list: list }

  context '#encode' do
    let(:encoded_field) { encoder.encode('myfield' => 'YES') }

    it 'converts field to relateiq field id from field name' do
      expect(encoded_field.keys[0]).to eq('5')
    end

    it 'encodes values in an array with a raw hash key' do
      expected = { '5' => [{ 'raw' => 'YES' }] }
      expect(encoded_field).to eq(expected)
    end

    it 'can have multiple field values' do
      actual = encoder.encode('myfield' => ['test 1', 'NO'])
      expected = { '5' => [{ 'raw' => 'test 1' }, { 'raw' => 'NO' }] }
      expect(actual).to eq(expected)
    end

    it 'throws an exception when field is not found' do
      expect { encoder.encode('fail' => 'bla') }.to raise_error(RelateIq::Utils::FieldNotFoundError)
    end

    it 'encodes list options to their appropriate ids' do
      input = { 'listfield' => ['loval 1', 'loval 2'] }
      expected = { '6' => [{ 'raw' => '9' }, { 'raw' => '10' }] }
      expect(encoder.encode(input)).to eq(expected)
    end

    it 'does not return a field if value is nil' do
      input = { 'listfield' => nil }
      expect(encoder.encode(input)).to eq({})
    end

    it 'returns an error when list option is not found' do
      input = { 'listfield' => 'not a real value' }
      expect { encoder.encode(input) }.to raise_error(RelateIq::Utils::FieldListOptionNotFoundError)
    end

    it 'returns an empty hash when the input is nil' do
      expect(encoder.encode(nil)).to eq({})
    end
  end

  context '#decode' do
    it 'can decode a field into a name value hash' do
      input = { '5' => [{ raw: 'YES' }] }
      expected = { 'myfield' => 'YES' }
      expect(encoder.decode(input)).to eq(expected)
    end

    it 'can decode a field with multiple values' do
      input = { '5' => [{ raw: 'test 1' }, { raw: 'NO' }] }
      expected = { 'myfield' => ['test 1', 'NO'] }
      expect(encoder.decode(input)).to eq(expected)
    end

    it 'decodes list options to their appropriate ids' do
      input = { '6' => [{ raw: '9' }, { raw: '10' }] }
      expected = { 'listfield' => ['loval 1', 'loval 2'] }
      expect(encoder.decode(input)).to eq(expected)
    end

    it 'returns an error when list option is not found' do
      input = { '6' => [{ raw: '900' }] }
      expect { encoder.decode(input) }.to raise_error(RelateIq::Utils::FieldListOptionNotFoundError)
    end

    it 'returns an empty hash when the input is nil' do
      expect(encoder.encode(nil)).to eq({})
    end
  end
end
