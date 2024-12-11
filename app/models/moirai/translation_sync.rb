module Moirai
  class TranslationSync
    def initialize
      @translations = Moirai::Translation.all
    end

    def synchronize
      Rails.logger.info "Synchronizing translations..."
      @translations.each do |translation|
        translation.destroy if translation.in_sync_with_file?
      end
      Rails.logger.info "Synchronization complete."
    end
  end
end
