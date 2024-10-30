require "test_helper"

module Moirai
  class TranslationTest < ActiveSupport::TestCase
    def setup
      @valid_translation = Translation.new(key: "hello", locale: "en", value: "Hello")
    end

    test ".by_file_path" do
      translation1 = Translation.create!(key: "locales.german", value: "Italian", locale: "en")
      translation2 = Translation.create!(key: "locales.italian", value: "Italian", locale: "en")
      translation3 = Translation.create!(key: "locales.german", value: "Italian", locale: "de")

      assert_equal [translation1, translation2], Translation.by_file_path(Rails.root.join("config/locales/en.yml").to_s)
      assert_equal [translation3], Translation.by_file_path(Rails.root.join("config/locales/de.yml").to_s)
    end

    test "should be valid with valid attributes" do
      File.stub :exist?, true do
        assert @valid_translation.valid?
      end
    end

    test "should be invalid without key" do
      @valid_translation.key = nil
      assert_not @valid_translation.valid?
      assert_includes @valid_translation.errors[:key], "can't be blank"
    end

    test "should be invalid without locale" do
      @valid_translation.locale = nil
      assert_not @valid_translation.valid?
      assert_includes @valid_translation.errors[:locale], "can't be blank"
    end

    test "should be invalid without value" do
      @valid_translation.value = nil
      assert_not @valid_translation.valid?
      assert_includes @valid_translation.errors[:value], "can't be blank"
    end
  end
end
