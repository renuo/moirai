# frozen_string_literal: true

module Moirai
  class KeyFinder
    include I18n::Backend::Base

    # Mutex to ensure that concurrent translations loading will be thread-safe
    MUTEX = Mutex.new

    def initialize
      load_translations
    end

    # TODO: remove locale default
    # Returns all the file_paths where the key is found, including gems.
    def file_paths_for(key, locale: I18n.locale)
      return [] if key.blank?

      locale ||= I18n.locale
      moirai_translations[locale.to_sym].select do |_filename, data|
        data.dig(*key.split(".")).present?
      end.map { |k, _| k }.sort { |file_path| file_path.start_with?(Rails.root.to_s) ? 0 : 1 }
    end

    def store_moirai_translations(filename, locale, data, options)
      moirai_translations[locale] ||= Concurrent::Hash.new

      locale = locale.to_sym
      moirai_translations[locale] ||= Concurrent::Hash.new
      moirai_translations[locale][filename] = data.with_indifferent_access
    end

    def moirai_translations(do_init: false)
      @moirai_translations ||= Concurrent::Hash.new do |h, k|
        MUTEX.synchronize do
          h[k] = Concurrent::Hash.new
        end
      end
    end

    def load_file(filename)
      type = File.extname(filename).tr(".", "").downcase
      raise I18n::UnknownFileType.new(type, filename) unless respond_to?(:"load_#{type}", true)
      data, keys_symbolized = send(:"load_#{type}", filename)
      unless data.is_a?(Hash)
        raise I18n::InvalidLocaleData.new(filename, "expects it to return a hash, but does not")
      end
      data.each do |locale, d|
        store_moirai_translations(filename, locale, d || {}, skip_symbolize_keys: keys_symbolized)
      end

      data
    end
  end
end
