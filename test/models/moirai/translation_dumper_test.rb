# frozen_string_literal: true

require "test_helper"

module Moirai
  class TranslationDumperTest < ActiveSupport::TestCase
    setup do
      @translation_dumper = TranslationDumper.new
      @de_relative_file_path = Pathname.new("config/locales/de.yml")
      @de_file_path = Rails.root.join(@de_relative_file_path).to_s
      @it_relative_file_path = Pathname.new("config/locales/it.yml")
      @it_file_path = Rails.root.join(@it_relative_file_path).to_s
    end

    test "it returns an empty list if there are no translations overridden" do
      assert_empty @translation_dumper.call
    end

    test "it returns  a list of files and their new content" do
      Moirai::Translation.create!(file_path: @de_file_path,
        locale: "de",
        key: "locales.italian",
        value: "Italianese")

      changes = @translation_dumper.call
      assert_equal 1, changes.length
      assert_equal @de_relative_file_path, changes[0][:file_path]
      content = YAML.load(changes[0][:content], symbolize_names: true)
      assert_equal "Italianese", content.dig(:de, :locales, :italian)
    end

    test "it merges two changes on the same file" do
      Moirai::Translation.create!(file_path: @de_file_path,
        locale: "de",
        key: "locales.italian",
        value: "Italianese")
      Moirai::Translation.create!(file_path: @de_file_path,
        locale: "de",
        key: "locales.german",
        value: "Germanese")

      changes = @translation_dumper.call
      assert_equal 1, changes.length
      assert_equal @de_relative_file_path, changes[0][:file_path]
      content = YAML.load(changes[0][:content], symbolize_names: true)
      assert_equal "Italianese", content.dig(:de, :locales, :italian)
      assert_equal "Germanese", content.dig(:de, :locales, :german)
    end

    test "it returns two changes for separate files" do
      Moirai::Translation.create!(file_path: @de_file_path,
        locale: "de",
        key: "locales.italian",
        value: "Italianese")
      Moirai::Translation.create!(file_path: @it_file_path,
        locale: "it",
        key: "locales.german",
        value: "Germanese")

      changes = @translation_dumper.call
      assert_equal 2, changes.length

      assert_equal @de_relative_file_path, changes[0][:file_path]
      de_content = YAML.load(changes[0][:content], symbolize_names: true)
      assert_equal "Italianese", de_content.dig(:de, :locales, :italian)

      assert_equal @it_relative_file_path, changes[1][:file_path]
      it_content = YAML.load(changes[1][:content], symbolize_names: true)
      assert_equal "Germanese", it_content.dig(:it, :locales, :german)
    end
  end
end
