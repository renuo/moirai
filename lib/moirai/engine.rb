# frozen_string_literal: true

module Moirai
  class Engine < ::Rails::Engine
    isolate_namespace Moirai

    config.generators do |generator|
      generator.orm :active_record
    end

    config.after_initialize do
      moirai_backend = I18n::Backend::Moirai.new
      moirai_backend.eager_load!
      I18n.backend = I18n::Backend::Chain.new(moirai_backend, I18n.backend)
    end

    # TODO: how to do this without rewriting the entire method?
    # https://github.com/rails/rails/blob/main/actionview/lib/action_view/helpers/translation_helper.rb#L122
    initializer "moirai.override_translation_helper" do
      ActiveSupport.on_load(:action_view) do
        module ActionView::Helpers::TranslationHelper # rubocop:disable Lint/ConstantDefinitionInBlock
          alias_method :original_translate, :translate

          def translate(key, **options)
            value = original_translate(key, **options)

            if moirai_edit_enabled?
              moirai_translations = I18n.backend.backends.find { |b| b.respond_to?(:moirai_translations) }.moirai_translations
              file_path = moirai_translations[I18n.locale][scope_key_by_partial(key)]

              render(partial: "moirai/translation_files/form",
                locals: {key: scope_key_by_partial(key),
                         file_path: file_path,
                         value: value})
            else
              value
            end
          end

          alias_method :t, :translate

          def moirai_edit_enabled?
            params[:moirai] == "true"
          end
        end
      end
    end
  end
end
