module RelateIq
  class Account
    attr_accessor :id, :name

    def self.resource
      @resource ||= RelateIq::ServiceFactory.get_endpoint('accounts')
    end

    def self.find(id)
      from_json(resource["#{id}"].get)
    end

    def self.create(attrs = {})
      RelateIq::Account.new(attrs).save
    end

    def self.from_json(json_string)
      account_hash = JSON.parse(json_string, symbolize_names: true)
      RelateIq::Account.new(account_hash)
    end

    def initialize(attrs = {})
      @id = attrs.fetch(:id, nil)
      @name = attrs.fetch(:name, nil)
    end

    def to_json
      account_hash = {
        name: @name
      }
      account_hash[:id] = id if id
      account_hash.to_json
    end

    def save
      if id
        RelateIq::Account.from_json(RelateIq::Account.resource["#{id}"].put(to_json))
      else
        RelateIq::Account.from_json(RelateIq::Account.resource.post(to_json))
      end
    end
  end
end
