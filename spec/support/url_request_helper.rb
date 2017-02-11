module URLRequest
  module JsonHelpers
    def json_response
      @json_reponse ||= JSON.parse(response.body, symbolize_names: true)
    end
  end
end
