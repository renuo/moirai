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
    def file_path_for(key, locale: I18n.locale)
      locale ||= I18n.locale
      moirai_translations[locale.to_sym][key]
    end

    def store_moirai_translations(filename, locale, data, options)
      moirai_translations[locale] ||= Concurrent::Hash.new
      flatten_data = flatten_hash(filename, data)
      flatten_data = I18n::Utils.deep_symbolize_keys(flatten_data) unless options.fetch(:skip_symbolize_keys, false)
      I18n::Utils.deep_merge!(moirai_translations[locale], flatten_data)
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

    def flatten_hash(filename, hash, parent_key = "", result = {})
      hash.each do |key, value|
        new_key = parent_key.empty? ? key.to_s : "#{parent_key}.#{key}"
        case value
        when Hash
          flatten_hash(filename, value, new_key, result)
        when Array
          value.each_with_index do |item, index|
            array_key = "#{new_key}.#{index}"
            if item.is_a?(Hash)
              flatten_hash(filename, item, array_key, result)
            else
              result[array_key] = filename
            end
          end
        else
          result[new_key] = filename
        end
      end
      result
    end
  end
end
