# frozen_string_literal: true

require "moirai/version"
require "moirai/engine"
require "moirai/authentication_strategy"
require "moirai/basic_auth_strategy"
require "moirai/pull_request_creator"
require "i18n/backend/moirai"
require "i18n/backend/moirai_tags"

module Moirai
  class << self
    attr_accessor :authentication_strategy

    def configure
      yield self
    end
  end

  self.authentication_strategy = BasicAuthStrategy
end
