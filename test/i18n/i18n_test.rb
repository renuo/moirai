# frozen_string_literal: true

require "test_helper"

class I18nExtensionsTest < ActiveSupport::TestCase
  test "it correctly translates using .translate and .translate_to_original" do
    assert_equal "Italienisch", I18n.t("locales.italian", locale: :de)

    Moirai::Translation.create!(locale: "de", key: "locales.italian", value: "Italianese")

    assert_equal 1, Moirai::Translation.count
    assert_equal "Italianese", I18n.t("locales.italian", locale: :de)
    assert_equal "Italienisch", I18n.translate_to_original("locales.italian", :de)
  end
end
