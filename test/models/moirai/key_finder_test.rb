# frozen_string_literal: true

require "test_helper"

module Moirai
  class KeyFinderTest < ActiveSupport::TestCase
    def setup
      @key_finder = KeyFinder.new
    end
    test "it finds the file path of a given key" do
      assert_match %r{config/locales/de.yml}, @key_finder.file_paths_for("locales.italian", locale: :de).first
      assert_match %r{config/locales/de.yml}, @key_finder.file_paths_for("locales.italian", locale: "de").first
      assert_match %r{config/locales/it.yml}, @key_finder.file_paths_for("locales.italian", locale: :it).first
      assert_match %r{config/locales/another.de.yml},
        @key_finder.file_paths_for("enumerations.countries.ch", locale: :de).first
    end

    test "it finds parent keys" do
      assert_match %r{config/locales/en.yml}, @key_finder.file_paths_for("buttons.very.much", locale: :en).first
    end

    test "it returns an empty array for an empty key" do
      assert_empty @key_finder.file_paths_for("", locale: :en)
    end

    test "it finds keys in gems" do
      assert_match %r{active_support/locale/en.yml}, @key_finder.file_paths_for("date.month_names", locale: :en).first
    end

    test "it returns local files before gem files" do
      file_paths = @key_finder.file_paths_for("date.formats.short", locale: :en)
      assert_match %r{config/locales/rails.en.yml}, file_paths.first
      assert_match %r{active_support/locale/en.yml}, file_paths.second
    end

    test "it returns nil if there is not match" do
      assert_empty @key_finder.file_paths_for("missing.key")
      assert_empty @key_finder.file_paths_for("buttons.very.much.nested.only_german", locale: :en)
      assert @key_finder.file_paths_for("buttons.very.much.nested", locale: :en)
    end
  end
end
