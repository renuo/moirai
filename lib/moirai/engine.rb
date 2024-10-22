# frozen_string_literal: true

module Moirai
  class Engine < ::Rails::Engine
    isolate_namespace Moirai

    config.generators do |generator|
      generator.orm :active_record
    end

    config.after_initialize do
      # I18n.backend.extend(I18n::Backend::MoiraiTags)
      I18n.backend = I18n::Backend::Chain.new(I18n::Backend::Moirai.new, I18n.backend)
    end

    # TODO: how to do this without rewriting the entire method?
    # https://github.com/rails/rails/blob/main/actionview/lib/action_view/helpers/translation_helper.rb#L122
    initializer 'moirai.override_translation_helper' do
      ActiveSupport.on_load(:action_view) do
        module ActionView::Helpers::TranslationHelper
          def translate(key, **options)
            return key.map { |k| translate(k, **options) } if key.is_a?(Array)
            key = key&.to_s unless key.is_a?(Symbol)

            alternatives = if options.key?(:default)
                             options[:default].is_a?(Array) ? options.delete(:default).compact : [options.delete(:default)]
                           end

            options[:raise] = true if options[:raise].nil? && ActionView::Helpers::TranslationHelper.raise_on_missing_translations
            default = MISSING_TRANSLATION

            translation = while key || alternatives.present?
                            if alternatives.blank? && !options[:raise].nil?
                              default = NO_DEFAULT # let I18n handle missing translation
                            end

                            key = scope_key_by_partial(key)

                            translated = ActiveSupport::HtmlSafeTranslation.translate(key, **options, default: default)

                            break translated unless translated == MISSING_TRANSLATION

                            if alternatives.present? && !alternatives.first.is_a?(Symbol)
                              break alternatives.first && I18n.translate(nil, **options, default: alternatives)
                            end

                            first_key ||= key
                            key = alternatives&.shift
                          end

            if key.nil? && !first_key.nil?
              translation = missing_translation(first_key, options)
              key = first_key
            end

            block_given? ? yield(translation, key) : translation
          end
          alias :t :translate
        end
      end
    end
  end
end
