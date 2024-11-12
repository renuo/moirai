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
      file_translation = file_value
      file_translation.present? && file_translation == value
    end

    def file_value
      return nil unless file_path

      file_handler = TranslationFileHandler.new
      file_content = file_handler.parse_file(file_path)
      file_content[key]
    end
  end
end
