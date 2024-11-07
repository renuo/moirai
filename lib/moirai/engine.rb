# frozen_string_literal: true

module Moirai
  class Engine < ::Rails::Engine
    isolate_namespace Moirai

    config.generators do |generator|
      generator.orm :active_record
    end

    config.after_initialize do
      I18n.backend = I18n::Backend::Chain.new(I18n::Backend::Moirai.new, I18n.backend)
    end

    initializer "moirai.override_translation_helper" do
      ActiveSupport.on_load(:action_view) do
        module ActionView::Helpers::TranslationHelper # rubocop:disable Lint/ConstantDefinitionInBlock
          alias_method :original_translate, :translate

          def translate(key, **options)
            value = original_translate(key, **options)

            if moirai_edit_enabled?
              @key_finder ||= Moirai::KeyFinder.new

              form_html = render(partial: "moirai/translation_files/form",
                locals: {key: scope_key_by_partial(key),
                         locale: I18n.locale,
                         value: value})

              SafeBufferWrapper.new(form_html)
            else
              value
            end
          end

          alias_method :t, :translate

          def moirai_edit_enabled?
            params[:moirai] == "true"
          end

          class SafeBufferWrapper < String
            def initialize(content)
              super(content)
            end

            def html_safe
              self
            end
          end
        end
      end
    end
  end
end
