# frozen_string_literal: true

require "test_helper"
require "moirai/translation_helper"

class I18nExtensionsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TranslationHelper

  test "it correctly translates using .translate and .translate_without_moirai" do
    assert_equal "Italienisch", I18n.t("locales.italian", locale: :de)

    Moirai::Translation.create!(locale: "de", key: "locales.italian", value: "Italianese")

    assert_equal 1, Moirai::Translation.count
    assert_equal "Italianese", I18n.t("locales.italian", locale: :de)
    assert_equal "Italienisch", I18n.translate_without_moirai("locales.italian", :de)
  end

  test "the view helper correctly translates No" do
    assert_equal false, t("option_no", locale: :it)
  end
end
