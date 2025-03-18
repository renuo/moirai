# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../test/dummy/config/environment"
require "rails/test_help"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "moirai"

require "minitest/autorun"

raise StandardError, "You must set MOIRAI_GITHUB_REPO_NAME env variable to run the tests" if ENV["MOIRAI_GITHUB_REPO_NAME"].nil?
raise StandardError, "You must set MOIRAI_GITHUB_ACCESS_TOKEN env variable to run the tests" if ENV["MOIRAI_GITHUB_ACCESS_TOKEN"].nil?
