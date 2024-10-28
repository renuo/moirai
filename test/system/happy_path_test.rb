# frozen_string_literal: true

require "application_system_test_case"

class HappyPathTest < ApplicationSystemTestCase
  def test_index
    visit "/"
    assert_text page, "English"

    visit root_path(locale: :de)

    assert_text page, "Italienisch"
    refute_text page, "Italianese"

    Moirai::Translation.create!(file_path: Rails.root.join("config/locales/de.yml"),
      locale: "de",
      key: "locales.italian",
      value: "Italianese")

    visit root_path(locale: :de)

    assert_text page, "Italianese"
    refute_text page, "Italienisch"
  end

  def test_inline_editors
    visit "/?moirai=true"
    assert_key_editable page, "buttons.very.much.nested.only_english"
    refute_key_editable page, "buttons.very.much.nested.only_italian"
    refute_key_editable page, "buttons.very.much.nested.only_german"

    visit "/?locale=de&moirai=true"
    refute_key_editable page, "buttons.very.much.nested.only_english"
    refute_key_editable page, "buttons.very.much.nested.only_italian"
    assert_key_editable page, "buttons.very.much.nested.only_german"

    visit "/?locale=it&moirai=true"
    refute_key_editable page, "buttons.very.much.nested.only_english"
    assert_key_editable page, "buttons.very.much.nested.only_italian"
    refute_key_editable page, "buttons.very.much.nested.only_german"
  end

  def assert_key_editable(page, key)
    assert_selector page, "[data-controller=\"moirai-translation\"][data-key=\"#{key}\"]"
  end

  def refute_key_editable(page, key)
    refute_selector page, "[data-controller=\"moirai-translation\"][data-key=\"#{key}\"]"
  end
end
