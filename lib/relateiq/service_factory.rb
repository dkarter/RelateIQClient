module RelateIq
  class ServiceFactory
    def self.get_endpoint(endpoint)
      RestClient::Resource.new(
        "#{RelateIq.configuration.base_url}/#{endpoint}",
        user: RelateIq.configuration.username,
        password: RelateIq.configuration.password,
        headers: { content_type: :json, accept: :json }
      )
    end
  end
end
