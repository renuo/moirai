# frozen_string_literal: true

require "test_helper"

module Moirai
  class TranslationDumperTest < ActiveSupport::TestCase
    setup do
      @translation_dumper = TranslationDumper.new
      @de_relative_file_path = Pathname.new("./config/locales/de.yml").to_s
      @de_file_path = Rails.root.join(@de_relative_file_path).to_s
      @it_relative_file_path = Pathname.new("./config/locales/it.yml").to_s
      @it_file_path = Rails.root.join(@it_relative_file_path).to_s
    end

    test "it returns an empty list if there are no translations overridden" do
      assert_empty @translation_dumper.call
    end

    test "it returns  a list of files and their new content" do
      Moirai::Translation.create!(locale: "de",
        key: "locales.italian",
        value: "Italianese")

      changes = @translation_dumper.call
      assert_equal 1, changes.length
      assert_equal @de_relative_file_path, changes[0].file_path
      content = YAML.safe_load(changes[0].content, symbolize_names: true)
      assert_equal "Italianese", content.dig(:de, :locales, :italian)
    end

    test "it merges two changes on the same file" do
      Moirai::Translation.create!(locale: "de", key: "locales.italian", value: "Italianese")
      Moirai::Translation.create!(locale: "de", key: "locales.german", value: "Germanese")

      changes = @translation_dumper.call
      assert_equal 1, changes.length
      assert_equal @de_relative_file_path, changes[0].file_path
      content = YAML.safe_load(changes[0].content, symbolize_names: true)
      assert_equal "Italianese", content.dig(:de, :locales, :italian)
      assert_equal "Germanese", content.dig(:de, :locales, :german)
    end

    test "it returns two changes for separate files" do
      Moirai::Translation.create!(locale: "de", key: "locales.italian", value: "Italianese")
      Moirai::Translation.create!(locale: "it", key: "locales.german", value: "Germanese")

      changes = @translation_dumper.call
      assert_equal 2, changes.length
      assert_equal @de_relative_file_path, changes[0].file_path
      de_content = YAML.safe_load(changes[0].content, symbolize_names: true)
      assert_equal "Italianese", de_content.dig(:de, :locales, :italian)

      assert_equal @it_relative_file_path, changes[1].file_path
      it_content = YAML.safe_load(changes[1].content, symbolize_names: true)
      assert_equal "Germanese", it_content.dig(:it, :locales, :german)
    end

    test "it takes the latest of two changes" do
      Moirai::Translation.create!(locale: "de",
        key: "locales.italian",
        value: "Italianese Recent")
      Moirai::Translation.create!(locale: "de",
        key: "locales.italian",
        value: "Italianese Old",
        created_at: 2.days.ago)

      changes = @translation_dumper.call
      assert_equal 1, changes.length
      assert_equal @de_relative_file_path, changes[0].file_path
      content = YAML.safe_load(changes[0].content, symbolize_names: true)
      assert_equal "Italianese Recent", content.dig(:de, :locales, :italian)
    end

    test "it adds new keys to the LOCALE.yml file by default" do
      Moirai::Translation.create!(locale: "de", key: "this.is.new", value: "Very new")
      changes = @translation_dumper.call
      assert_equal 1, changes.length
      assert_equal @de_relative_file_path, changes[0].file_path
    end

    test "it adds new keys to the file owning their parent key" do
      Moirai::Translation.create!(locale: "de", key: "locales.french", value: "Franzosisch")
      Moirai::Translation.create!(locale: "de", key: "enumerations.countries.it", value: "Italien")
      changes = @translation_dumper.call
      assert_equal 2, changes.length
      assert_equal @de_relative_file_path, changes[0].file_path
      assert_equal "./config/locales/another.de.yml", changes[1].file_path
    end

    test "it adds keys belonging to gems to LOCALE.yml file by default" do
      Moirai::Translation.create!(locale: "en", key: "time.formats.default", value: "%d.%m.%Y")
      changes = @translation_dumper.call
      assert_equal 1, changes.length
      assert_equal "./config/locales/en.yml", changes[0].file_path
    end

    test "it finds the most appropriate path" do
      assert_match(%r{config/locales/de.yml}, @translation_dumper.best_file_path_for("date.formats.default", :de))
      assert_match(%r{config/locales/rails.en.yml}, @translation_dumper.best_file_path_for("date.formats.default", :en))
      assert_match(%r{config/locales/rails.en.yml}, @translation_dumper.best_file_path_for("date.formats.short", :en))
      assert_match(%r{config/locales/rails.en.yml}, @translation_dumper.best_file_path_for("date.order", :en))
    end
  end
end
