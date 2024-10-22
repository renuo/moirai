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

    initializer 'moirai.override_translation_helper' do
      ActiveSupport.on_load(:action_view) do
        module ActionView::Helpers::TranslationHelper
          def translate(key, **options)
            # Call the original method to retain full functionality
            result = super

            # Wrap the result in your custom tag
            content_tag(:span, result, class: 'custom-translation')
          end

          alias :t :translate
        end
      end
    end
  end
end
