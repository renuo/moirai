# frozen_string_literal: true

require "moirai/version"
require "i18n/extensions/i18n"
require "i18n/backend/moirai"
require "moirai/engine"
require "moirai/configuration"
require "moirai/pull_request_creator"

module Moirai
  mattr_accessor :enable_inline_editing
end
