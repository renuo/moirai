module Moirai
  class TranslationSync
    def initialize
      @translations = Moirai::Translation.all
      @file_handler = TranslationFileHandler.new
      @file_translations = load_locale_files
    end

    def synchronize
      Rails.logger.info "Synchronizing translations..."
      @translations.each do |translation|
        translation.destroy if translation_in_sync?(translation)
      end
      Rails.logger.info "Synchronization complete."
    end

    private

    def load_locale_files
      @file_handler.file_paths.each_with_object({}) do |file_path, translations|
        locale = @file_handler.get_first_key(file_path)
        translation_keys = @file_handler.parse_file(file_path)
        translations.merge!(namespaced_keys(translation_keys, locale))
      end
    end

    def namespaced_keys(translation_keys, locale)
      translation_keys.transform_keys { |key| "#{locale}.#{key}" }
    end

    def translation_in_sync?(translation)
      file_translation = @file_translations["#{translation.locale}.#{translation.key}"]
      file_translation.present? && file_translation == translation.value
    end
  end
end
