module RelateIq
  class Contact
    attr_accessor :id,
                  :first_name,
                  :last_name,
                  :email,
                  :phone,
                  :address,
                  :city,
                  :state,
                  :zipcode,
                  :company,
                  :title,
                  :twitter,
                  :linkedin

    def self.resource
      @resource ||= ServiceFactory.get_endpoint('contacts')
    end

    def self.find(id)
      from_json(resource["#{id}"].get)
    end

    def self.find_by_email(email)
      from_json(resource["?properties.email=#{email}"].get)
    end

    def self.create(attrs)
      Contact.new(attrs).save
    end

    def full_name
      return nil unless first_name || last_name
      "#{first_name} #{last_name}"
    end

    def full_address
      return nil unless address || city || state || zipcode
      "#{address}, #{city}, #{state} #{zipcode}"
    end

    def save
      if id
        Contact.from_json(Contact.resource["#{id}"].put to_json)
      else
        Contact.from_json(Contact.resource.post to_json)
      end
    end

    def self.from_json(json_string)
      contact_hash = JSON.parse(json_string, symbolize_names: true)
      if contact_hash.key? :objects
        contact_hash[:objects].map { |li| Contact.new(li) }
      else
        Contact.new(contact_hash)
      end
    end

    def initialize(attrs = {})
      if attrs.key? :properties
        initialize_from_api(attrs)
      else
        initialize_by_user(attrs)
      end
    end

    def to_json
      riq_hash = { properties: { email: [{ value: @email }] } }
      riq_hash[:id] = id if id
      inject_property_value_hash(riq_hash[:properties], 'name', full_name)
      inject_property_value_hash(riq_hash[:properties], 'phone', phone)
      inject_property_value_hash(riq_hash[:properties], 'address', address)
      inject_property_value_hash(riq_hash[:properties], 'liurl', linkedin)
      inject_property_value_hash(riq_hash[:properties], 'twhan', twitter)
      inject_property_value_hash(riq_hash[:properties], 'company', company)
      inject_property_value_hash(riq_hash[:properties], 'title', title)
      riq_hash.to_json
    end

    private

    def inject_property_value_hash(hash, name, value)
      if value.is_a? Array
        hash.merge!(name => value.map { |v| property_value(v) })
      else
        hash.merge!(value ? { name => [property_value(value)] } : {})
      end
    end

    def property_value(value)
      { value: value }
    end

    def array_or_single(value)
      value.count > 1 ? value : value[0]
    end

    def initialize_by_user(attrs)
      @id = attrs.fetch(:id, nil)
      @email = attrs.fetch(:email, nil)
      @first_name = attrs.fetch(:first_name, nil)
      @last_name = attrs.fetch(:last_name, nil)
      @title = attrs.fetch(:title, nil)
      @company = attrs.fetch(:company, nil)
      @phone = attrs.fetch(:phone, nil)
      @address = attrs.fetch(:address, nil)
      @linkedin = attrs.fetch(:linkedin, nil)
      @twitter = attrs.fetch(:twitter, nil)
    end

    def initialize_from_api(attrs)
      # extract attributes from properties
      attrs[:properties].map { |k, v| attrs.merge!(k => extract_values(v)) }
      attrs.delete(:properties)
      # rename some keys
      attrs[:twitter] = attrs.delete(:twhan)
      attrs[:linkedin] = attrs.delete(:liurl)
      initialize_by_user(attrs)
    end

    def extract_values(api_values)
      return nil if api_values.nil?
      array_or_single api_values.map { |v| v[:value] }
    end
  end
end
