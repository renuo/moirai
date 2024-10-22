# frozen_string_literal: true

require "application_system_test_case"

class TranslationFilesTest < ApplicationSystemTestCase
  include Moirai::Engine.routes.url_helpers

  def setup
    @file_handler = Moirai::TranslationFileHandler.new
    @file_path = Rails.root.join("config/locales/de.yml").to_s
  end

  def test_index
    visit moirai_translation_files_path

    @file_handler.file_paths.each do |path|
      assert_text page, File.basename(path)
    end
  end

  def test_show
    file_id = Digest::SHA256.hexdigest(@file_path)
    @file_handler.parse_file(@file_path)

    visit moirai_translation_file_path(file_id)

    assert_text page, "locales.german"
    assert_text page, "Deutsch"
  end

  def test_create_translation
    @file_path = @file_handler.file_paths.first
    file_id = Digest::SHA256.hexdigest(@file_path)
    @file_handler.parse_file(@file_path)

    visit moirai_translation_file_path(file_id)

    within "#moirai-locales.german-new" do
      fill_in "translation[value]", with: "Hochdeutsch"
    end

    assert_text page, "Translation greeting was successfully created."
  end

  def test_update_translation
    translation = Moirai::Translation.create!(key: "greeting", locale: "en", value: "Hi", file_path: @file_path)
    file_id = Digest::SHA256.hexdigest(translation.file_path)
    @file_handler.parse_file(translation.file_path)

    visit moirai_translation_file_path(file_id)

    within "#moirai-locales.german-en" do
      fill_in "translation[value]", with: "Hochdeutsch"
    end

    assert_text "Translation greeting was successfully updated."
  end
end
