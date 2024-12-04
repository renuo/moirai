# frozen_string_literal: true

module Moirai
  class Translation < Moirai::ApplicationRecord
    validates_presence_of :key, :locale, :value

    # what if the key is present in multiple file_paths?
    def file_path
      @key_finder ||= KeyFinder.new
      @key_finder.file_paths_for(key, locale: locale).first
    end

    def self.by_file_path(file_path)
      key_finder = KeyFinder.new
      all.select { |translation| key_finder.file_paths_for(translation.key, locale: translation.locale).include?(file_path) }
    end

    def in_sync_with_file?
      translation_without_moirai = I18n.translate_without_moirai(key, locale)
      translation_without_moirai.present? && translation_without_moirai == value
    end
  end
end
