# test/services/moirai/translation_updater_test.rb
require "test_helper"

class Moirai::TranslationUpdaterTest < ActiveSupport::TestCase
  def setup
    @file_path = Rails.root.join("test", "fixtures", "files", "en.yml")
    @translation = Moirai::Translation.new(
      file_path: @file_path.to_s,
      locale: "en",
      key: "number.format.round_mode",
      value: "up"
    )

    # Create a sample file for testing
    File.write(@file_path, <<~YAML)
      en:
        number:
          format:
            round_mode: down
          currency:
            format: default
    YAML
  end

  def teardown
    # Clean up the file after test
    File.delete(@file_path) if File.exist?(@file_path)
  end

  def test_updates_translation_in_file
    updater = Moirai::TranslationUpdater.new(@translation)
    assert updater.update_translation

    updated_content = File.read(@file_path)
    assert_match(/round_mode: up/, updated_content)
  end

  def test_does_nothing_if_file_not_found
    invalid_translation = Moirai::Translation.new(file_path: "non_existent.yml")
    updater = Moirai::TranslationUpdater.new(invalid_translation)

    assert_not updater.update_translation
  end
end
