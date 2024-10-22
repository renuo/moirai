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
end
