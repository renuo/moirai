# frozen_string_literal: true

require "test_helper"

module Moirai
  class KeyFinderTest < ActiveSupport::TestCase
    test "it finds the file path of a given key" do
      key_finder = KeyFinder.new
      assert_match(%r{config/locales/de.yml}, key_finder.file_path_for("locales.italian", locale: :de))
      assert_match(%r{config/locales/de.yml}, key_finder.file_path_for("locales.italian", locale: "de"))
      assert_match(%r{config/locales/it.yml}, key_finder.file_path_for("locales.italian", locale: :it))
      assert_nil key_finder.file_path_for("missing.key")
    end
  end
end
