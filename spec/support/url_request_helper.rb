module URLRequest
  module JsonHelpers
    def json_response
      @json_response ||= JSON.parse(response.body, symbolize_names: true)
    end
  end

  module HeadersHelpers
    def api_header(version = 1)
      request.headers['Accept'] = "application/vnd.spicysoftwareinventory.v#{version}"
    end

    def api_response_format(format = Mime[:json])
      request.headers['Accept'] = "#{request.headers['Accept']},#{format}"
      request.headers['Content-Type'] = format.to_s
    end

    def include_default_accept_headers
      api_header
      api_response_format
    end

    def api_authorization_header(token)
      request.headers['Authorization'] = token
    end

    def create_and_authenticate_user(user_sym)
      user = FactoryGirl.create user_sym
      api_authorization_header user[:auth_token]
      return user
    end
  end

  module ErrorsHelpers
    def expect_422_unprocessable_entity
      user_response = json_response
      should respond_with 422
      expect(user_response).to have_key(:errors)

      return user_response
    end

    def expect_401_unauthorized
      user_response = json_response
      expect(user_response).to have_key(:errors)
      should respond_with 401

      return user_response
    end

    def expect_404_not_found
      response = json_response
      expect(response).to have_key(:errors)
      should respond_with 404

      return response
    end
  end
end
