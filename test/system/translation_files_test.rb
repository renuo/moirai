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

    ["config/locales/de.yml", "config/locales/en.yml", "config/locales/it.yml"].each do |relative_path|
      assert_text page, relative_path
    end
  end

  def test_show
    file_id = Digest::SHA256.hexdigest(@file_path)
    visit moirai_translation_file_path(file_id)

    assert_text page, "locales.german"
  end

  def test_create_translation
    visit moirai_translation_file_path(Digest::SHA256.hexdigest(Rails.root.join("config/locales/de.yml").to_s))

    within find("tr", text: "locales.german") do
      fill_in "translation[value]", with: "Hochdeutsch"
      find("input[type='submit'][value='Update']", visible: false).execute_script("this.click()")
    end
  end

  def test_update_translation
    Moirai::Translation.create!(key: "locales.german", locale: "en", value: "German")
    file_id = Digest::SHA256.hexdigest(Rails.root.join("config/locales/en.yml").to_s)

    visit moirai_translation_file_path(file_id)

    within find("tr", text: "locales.german") do
      fill_in "translation[value]", with: "Hochdeutsch"
      find("input[type='submit'][value='Update']", visible: false).execute_script("this.click()")
    end

    assert_equal "Hochdeutsch", Moirai::Translation.find_by(key: "locales.german", locale: "en").value

    assert_text "Translation locales.german was successfully updated."
  end
end
