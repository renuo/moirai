module I18n
  module Backend
    class Moirai < I18n::Backend::Simple # TODO: no need to extend the simple one. It does too much
      # TODO: mega inefficient. we don't want to perform a SQL query for each key!
      def translate(locale, key, options = EMPTY_HASH)
        overridden_translation = ::Moirai::Translation.find_by(locale: locale, key: key)
        if overridden_translation.present?
          overridden_translation.value
        end
      end

      # This method receives a locale, a data hash and options for storing translations.
      def store_translations(filename, locale, data, options = EMPTY_HASH)
        original = super(locale, data, options)
        store_moirai_translations(filename, locale, data, options)
        original
      end

      def store_moirai_translations(filename, locale, data, options)
        moirai_translations[locale] ||= Concurrent::Hash.new
        flatten_data = flatten_hash(filename, data)
        flatten_data = Utils.deep_symbolize_keys(flatten_data) unless options.fetch(:skip_symbolize_keys, false)
        Utils.deep_merge!(moirai_translations[locale], flatten_data)
      end

      def moirai_translations(do_init: false)
        @moirai_translations ||= Concurrent::Hash.new do |h, k|
          MUTEX.synchronize do
            h[k] = Concurrent::Hash.new
          end
        end
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

      def load_file(filename)
        type = File.extname(filename).tr(".", "").downcase
        raise UnknownFileType.new(type, filename) unless respond_to?(:"load_#{type}", true)
        data, keys_symbolized = send(:"load_#{type}", filename)
        unless data.is_a?(Hash)
          raise InvalidLocaleData.new(filename, "expects it to return a hash, but does not")
        end
        data.each { |locale, d| store_translations(filename, locale, d || {}, skip_symbolize_keys: keys_symbolized) }

        data
      end
    end
  end
end
