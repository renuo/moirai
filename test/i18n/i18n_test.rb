# frozen_string_literal: true

require "test_helper"

class I18nExtensionsTest < ActiveSupport::TestCase
  test "it correctly translates using .translate and .translate_without_moirai" do
    # Debugging: Check if the database table exists
    table_exists = ActiveRecord::Base.connection.data_source_exists?("moirai_translations")
    Rails.logger.debug("Database connection established: #{ActiveRecord::Base.connected?}")
    Rails.logger.debug("moirai_translations table exists: #{table_exists}")

    # Ensure the table exists, or raise an error to debug further
    assert table_exists, "The moirai_translations table does not exist in the test database."

    assert_equal "Italienisch", I18n.t("locales.italian", locale: :de)

    Moirai::Translation.create!(locale: "de", key: "locales.italian", value: "Italianese")

    assert_equal 1, Moirai::Translation.count
    assert_equal "Italianese", I18n.t("locales.italian", locale: :de)
    assert_equal "Italienisch", I18n.translate_without_moirai("locales.italian", :de)
  end
end
