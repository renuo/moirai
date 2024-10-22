require 'test_helper'

module Moirai
  class TranslationTest < ActiveSupport::TestCase
    def setup
      @valid_translation = Translation.new(key: 'hello', locale: 'en', file_path: '/valid/path/to/file')
      @invalid_translation = Translation.new(key: 'hello', locale: 'en', file_path: '/invalid/path/to/file')
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

    test "should be invalid without file_path" do
      @valid_translation.file_path = nil
      assert_not @valid_translation.valid?
      assert_includes @valid_translation.errors[:file_path], "can't be blank"
    end

    test "should be invalid if file_path does not exist" do
      File.stub :exist?, false do
        assert_not @invalid_translation.valid?
        assert_includes @invalid_translation.errors[:file_path], "must exist"
      end
    end
  end
end
