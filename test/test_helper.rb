# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../test/dummy/config/environment"
require "rails/test_help"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "moirai"

require "minitest/autorun"
