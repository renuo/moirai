# frozen_string_literal: true

require "test_helper"

module Moirai
  class TranslationSyncTest < ActiveSupport::TestCase
    setup do
      @de_file_path = Rails.root.join("config/locales/de.yml").to_s
      @original_de_content = YAML.load_file(@de_file_path)
    end

    teardown do
      File.write(@de_file_path, @original_de_content.to_yaml)
    end

    test "it synchronizes translations" do
      assert_equal "Italienisch", I18n.t("locales.italian", locale: :de)

      Moirai::Translation.create!(locale: "de", key: "locales.italian", value: "Italianese")

      assert_equal "Italianese", I18n.t("locales.italian", locale: :de)

      modified_de_yaml = {
        de: {
          locales: {
            italian: "Italianese"
          }
        }
      }
      File.write(@de_file_path, modified_de_yaml.to_yaml)

      # initialize the service here so that we have the correct data
      @translation_sync_service = Moirai::TranslationSync.new

      assert_difference -> { Moirai::Translation.count }, -1 do
        @translation_sync_service.synchronize
      end
    end

    test "it retains records that do not match locale files" do
      Moirai::Translation.create!(locale: "de", key: "locales.french", value: "Französisch")

      # initialize the service here so that we have the correct data
      @translation_sync_service = Moirai::TranslationSync.new

      assert_no_difference -> { Moirai::Translation.count } do
        @translation_sync_service.synchronize
      end
    end
  end
end
