# frozen_string_literal: true

require "application_system_test_case"

class TranslationFilesTest < ApplicationSystemTestCase
  def setup
    @file_handler = Moirai::TranslationFileHandler.new
    Moirai::TranslationFileHandler.stubs(:new).returns(@file_handler)
  end

  def test_index
    visit moirai_translation_files_path

    @file_handler.file_paths.each do |path|
      assert_text page, File.basename(path)
    end
  end

  def test_show
    file_path = @file_handler.file_paths.first
    file_id = Digest::SHA256.hexdigest(file_path)
    @file_handler.stubs(:parse_file).returns({"hello" => "world"})

    visit moirai_translation_file_path(file_id)

    assert_text page, "hello"
    assert_text page, "world"
  end

  def test_create_translation
    file_path = @file_handler.file_paths.first
    file_id = Digest::SHA256.hexdigest(file_path)
    @file_handler.stubs(:parse_file).returns({})

    visit moirai_translation_file_path(file_id)

    fill_in "Key", with: "greeting"
    fill_in "Locale", with: "en"
    fill_in "Value", with: "Hello"
    fill_in "File path", with: file_path
    click_button "Save"

    assert_text page, "Translation greeting was successfully created."
  end

  def test_update_translation
    translation = Moirai::Translation.create!(key: "greeting", locale: "en", value: "Hi", file_path: @file_handler.file_paths.first)
    file_id = Digest::SHA256.hexdigest(translation.file_path)
    @file_handler.stubs(:parse_file).returns({"greeting" => "Hi"})

    visit moirai_translation_file_path(file_id)

    fill_in "Key", with: "greeting"
    fill_in "Locale", with: "en"
    fill_in "Value", with: "Hello"
    fill_in "File path", with: translation.file_path
    click_button "Save"

    assert_text page, "Translation greeting was successfully updated."
  end
end
