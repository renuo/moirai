module Moirai
  module AuthenticationStrategy
    def authenticate(request)
      raise NotImplementedError, "Subclasses must implement the `authenticate` method"
    end
  end
end
