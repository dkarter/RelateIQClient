module RelateIq
  class List
    attr_accessor :id,
                  :title,
                  :list_type,
                  :modified_date,
                  :fields

    def initialize(attrs = {})
      if attrs.key? :listType
        initialize_from_api(attrs)
      else
        initialize_from_user(attrs)
      end
    end

    def self.resource
      @resource ||= ServiceFactory.get_endpoint('lists')
    end

    def self.all
      @all ||= from_json(resource.get)
    end

    def self.find_by_title(title)
      all.find { |l| l.title.downcase == title.downcase }
    end

    def self.find(id)
      all.find { |l| l.id == id }
    end

    def self.clean_cache
      @all = nil
    end

    def self.from_json(json_string)
      lists_hash = JSON.parse(json_string, symbolize_names: true)
      if lists_hash.key? :objects
        lists_hash[:objects].map { |li| List.new(li) }
      else
        List.new(lists_hash)
      end
    end

    def upsert_item(list_item_hash)
      list_item_hash.merge!(list_id: id)
      list_item_class.new(list_item_hash).save
    end

    def items_by_contact_id(contact_id)
      list_item_class.find_by_contact(id, contact_id)
    end

    private

    def list_item_class
      @list_item_class ||= ListItem
    end

    def initialize_from_api(attrs)
      @id = attrs.fetch(:id)
      @title = attrs.fetch(:title)
      @fields = attrs.fetch(:fields)
      @list_type = attrs.fetch(:listType)
      @modified_date = attrs.fetch(:modifiedDate)
    end

    def initialize_from_user(attrs)
      @id = attrs.fetch(:id, nil)
      @title = attrs.fetch(:title, nil)
      @list_type = attrs.fetch(:list_type, nil)
      @modified_date = attrs.fetch(:modified_date, nil)
      @fields = attrs.fetch(:fields, nil)
    end
  end
end
