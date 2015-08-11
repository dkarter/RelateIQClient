module RelateIq
  module Utils
    class FieldValueEncoder
      attr_accessor :list

      def initialize(attrs = {})
        @list = attrs.fetch(:list)
      end

      def encode(decoded_value)
        return {} if decoded_value.nil?
        name = decoded_value.keys[0]
        values = decoded_value.values[0]
        field = find_field_by_name(name)
        encoded_value = encode_values(field, values)
        return {} if encoded_value == []
        { "#{field[:id]}" =>  encoded_value }
      end

      def decode(encoded_value)
        return {} if encoded_value.nil?
        id = encoded_value.keys[0]
        values = encoded_value.values[0]
        field = find_field(id)
        { "#{field[:name]}" => decode_values(field, values) }
      end

      private

      def decode_values(field, field_values)
        result = []
        field_values.each { |fv| result << list_option_value(field, fv[:raw], 'id', 'display') }
        result.count > 1 ? result : result[0]
      end

      def encode_values(field, field_values)
        result = []
        to_array(field_values).each do |fv|
          list_option = list_option_value(field, fv, 'display', 'id')
          result << { 'raw' => list_option } unless list_option.nil?
        end
        result
      end

      def list_option_value(field, value, key, value_key)
        return nil if value.nil?
        list_options = field[:listOptions]
        if list_options && list_options.count > 0
          option = list_options.find { |lo| lo[key.to_sym].downcase == value.downcase }
          option ||= fail(FieldListOptionNotFoundError, key => value)
          option[value_key.to_sym]
        else
          value
        end
      end

      def find_field_by_name(name)
        list.fields.find { |f| f[:name] == name } || fail(FieldNotFoundError, name)
      end

      def find_field(id)
        list.fields.find { |f| f[:id] == id.to_s } || fail(FieldNotFoundError, id)
      end

      def to_array(value)
        value.is_a?(Array) ? value : [value]
      end
    end

    class FieldNotFoundError < StandardError; end
    class FieldListOptionNotFoundError < StandardError; end
  end
end
