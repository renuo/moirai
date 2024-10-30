# frozen_string_literal: true

module Moirai
  class Translation < Moirai::ApplicationRecord
    validates_presence_of :key, :locale

    def find_file_path
      @key_finder = KeyFinder.new
      @key_finder.file_path_for(key, locale: locale)
    end

    def self.by_file_path(file_path)
      key_finder = KeyFinder.new
      all.select { |translation| key_finder.file_path_for(translation.key, locale: translation.locale) == file_path }
    end
  end
end
