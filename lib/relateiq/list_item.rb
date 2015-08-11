module RelateIq
  class ListItem
    attr_accessor :list_id,
                  :id,
                  :name,
                  :account_id,
                  :contact_ids,
                  :field_values

    # field values always contains decoded values
    # for example { 'Status' => 'Application Submitted' }

    def initialize(attrs = {})
      if attrs.key? :listId
        initialize_from_api(attrs)
      else
        initialize_by_user(attrs)
      end
    end

    def initialize_by_user(attrs)
      @list_id = attrs.fetch(:list_id)
      @id = attrs.fetch(:id, nil)
      @name = attrs.fetch(:name, nil)
      @account_id = attrs.fetch(:account_id, nil)
      @contact_ids = attrs.fetch(:contact_ids, [])
      @field_values = attrs.fetch(:field_values, [])
    end

    def initialize_from_api(attrs)
      @list_id = attrs.fetch(:listId)
      @id = attrs.fetch(:id, nil)
      @name = attrs.fetch(:name, nil)
      @account_id = attrs.fetch(:accountId, nil)
      @contact_ids = attrs.fetch(:contactIds, [])
      @field_values = decode_field_values(attrs.fetch(:fieldValues, nil))
    end

    def self.resource(list_id)
      @resource ||= ServiceFactory.get_endpoint('lists')
      @resource["#{list_id}/listitems"]
    end

    def self.from_json(json_string)
      list_item_hash = JSON.parse(json_string, symbolize_names: true)
      if list_item_hash.key? :objects
        list_item_hash[:objects].map { |li| ListItem.new(li) }
      else
        ListItem.new(list_item_hash)
      end
    end

    def self.create(attrs)
      ListItem.new(attrs).save
    end

    def self.find_by_contact(list_id, contact_id)
      from_json(resource(list_id)["?contactIds=#{contact_id}"].get)
    end

    def save
      if id
        ListItem.from_json(ListItem.resource(list_id)["#{id}"].put to_json)
      else
        ListItem.from_json(ListItem.resource(list_id).post to_json)
      end
    end

    def to_json
      to_hash.to_json
    end

    private

    def to_hash
      result = { 'listId' => list_id }
      result.merge!('id' => id) if id
      result.merge!('name' => name) if name
      result.merge!('accountId' => account_id) if account_id && list.list_type == 'account'
      result.merge!('contactIds' => contact_ids) if contact_ids && contact_ids.count > 0
      result.merge!('fieldValues' => encode_field_values(field_values)) if field_values && field_values.count > 0
      result
    end

    def encode_field_values(values)
      return [] unless values
      encoder = field_value_encoder.new(list: list)
      encoded_values = {}
      values.each { |fv| encoded_values.merge!(encoder.encode(fv)) }
      encoded_values
    end

    def decode_field_values(values)
      return [] unless values
      encoder = field_value_encoder.new(list: list)
      values.map { |k, v| encoder.decode(k => v) }
    end

    def field_value_encoder
      @field_value_encoder ||= RelateIq::Utils::FieldValueEncoder
    end

    def list
      List.find(list_id)
    end
  end
end
