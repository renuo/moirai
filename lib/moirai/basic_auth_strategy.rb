module Moirai
  class BasicAuthStrategy < Moirai::AuthenticationStrategy
    def authenticate(request)
      return true if ENV["MOIRAI_BASICAUTH_NAME"].blank? || ENV["MOIRAI_BASICAUTH_PASSWORD"].blank?

      authenticate_with_http_basic(request) do |username, password|
        username == ENV["MOIRAI_BASICAUTH_NAME"] && password == ENV["MOIRAI_BASICAUTH_PASSWORD"]
      end
    end

    private

    def authenticate_with_http_basic(request)
      auth_header = request.headers["Authorization"]
      return false unless auth_header&.start_with?("Basic ")

      encoded_credentials = auth_header.split(" ", 2).last
      decoded_credentials = Base64.decode64(encoded_credentials).split(":", 2)
      yield decoded_credentials[0], decoded_credentials[1]
    end
  end
end
