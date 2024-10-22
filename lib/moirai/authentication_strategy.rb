module Moirai
  class AuthenticationStrategy
    def authenticate(request)
      raise NotImplementedError, "Subclasses must implement the `authenticate` method"
    end
  end
end
