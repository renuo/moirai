module I18n
  module Backend
    module MoiraiTags
      def translate(locale, key, options = EMPTY_HASH)
        value = super
        puts value
        value
      end
    end
  end
end
