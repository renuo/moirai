module I18n
  module Backend
    class Moirai < I18n::Backend::Simple
      # TODO: mega inefficient. we don't want to perform a SQL query for each key!
      def translate(locale, key, options = EMPTY_HASH)
        overridden_translation = ::Moirai::Translation.find_by(locale: locale, key: key)
        if overridden_translation.present?
          overridden_translation.value
        end
      end
    end
  end
end
