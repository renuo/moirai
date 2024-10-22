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
          # def translate(key, **options)
          #   return key.map { |k| translate(k, **options) } if key.is_a?(Array)
          #   key = key&.to_s unless key.is_a?(Symbol)
          #
          #   alternatives = if options.key?(:default)
          #                    options[:default].is_a?(Array) ? options.delete(:default).compact : [options.delete(:default)]
          #                  end
          #
          #   options[:raise] = true if options[:raise].nil? && ActionView::Helpers::TranslationHelper.raise_on_missing_translations
          #   default = MISSING_TRANSLATION
          #
          #   translation = while key || alternatives.present?
          #                   if alternatives.blank? && !options[:raise].nil?
          #                     default = NO_DEFAULT # let I18n handle missing translation
          #                   end
          #
          #                   key = scope_key_by_partial(key)
          #
          #                   translated = ActiveSupport::HtmlSafeTranslation.translate(key, **options, default: default)
          #
          #                   break translated unless translated == MISSING_TRANSLATION
          #
          #                   if alternatives.present? && !alternatives.first.is_a?(Symbol)
          #                     break alternatives.first && I18n.translate(nil, **options, default: alternatives)
          #                   end
          #
          #                   first_key ||= key
          #                   key = alternatives&.shift
          #                 end
          #
          #   if key.nil? && !first_key.nil?
          #     translation = missing_translation(first_key, options)
          #     key = first_key
          #   end
          #
          #   result = block_given? ? yield(translation, key) : translation
          #   content_tag("span", result, class: "moirai_whatever")
          # end
          # alias :t :translate
          alias :original_translate :translate

          def translate(key, **options)
            value = original_translate(key, **options)

            if moirai_edit_enabled?
              # TODO: cannot always assume that our backend is the first one, but we need to access moirai_translations
              moirai_translations = I18n.backend.backends.first.moirai_translations
              filepath = moirai_translations[I18n.locale][key]
              # content_tag("form", class: "moirai_form") do
              #   content_tag("input", nil, value: value) +
              #   content_tag("span", value, class: "moirai_whatever", data_controller: "moirai-key")
              # end

              content_tag(:form, action: moirai.moirai_create_or_update_translation_path(1), method: 'post') do
                hiddent_authenticity_token = content_tag(:input, nil, type: "hidden", name: "authenticity_token", value: form_authenticity_token, autocomplete:"off")
                hidden_key = content_tag(:input, nil, type: 'hidden', name: 'translation[key]', value: key)
                hidden_file_path = content_tag(:input, nil, type: 'hidden', name: 'translation[file_path]', value: filepath)
                hidden_locale = content_tag(:input, nil, type: 'hidden', name: 'translation[locale]', value: I18n.locale)
                text_field_value = content_tag(:input, nil, type: 'text', name: 'translation[value]', value: value)
                submit_button = content_tag(:input, nil, type: 'submit', value: 'Update', style: 'display: none;')

                hiddent_authenticity_token + hidden_key + hidden_file_path + hidden_locale + text_field_value + submit_button
              end
            else
              value
            end
          end

          alias :t :translate

          def moirai_edit_enabled?
            false
          end
        end
      end
    end
  end
end
