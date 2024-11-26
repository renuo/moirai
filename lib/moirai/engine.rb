# frozen_string_literal: true

module Moirai
  class Engine < ::Rails::Engine
    isolate_namespace Moirai

    config.generators do |generator|
      generator.orm :active_record
    end

    config.after_initialize do
      I18n.original_backend = I18n.backend
      table_created =
        begin
          ActiveRecord::Base.connection.is_a?(ActiveRecord::ConnectionAdapters::SQLite3Adapter) ||
            ActiveRecord::Base.connection.table_exists?("moirai_translations")
        rescue ActiveRecord::NoDatabaseError
          false
        end
      if table_created
        I18n.backend = I18n::Backend::Chain.new(I18n::Backend::Moirai.new, I18n.backend)
      else
        Rails.logger.warn("moirai disabled: tables have not been generated yet.")
      end
    end

    # TODO: how to do this without rewriting the entire method?
    # https://github.com/rails/rails/blob/main/actionview/lib/action_view/helpers/translation_helper.rb#L122
    initializer "moirai.override_translation_helper" do
      ActiveSupport.on_load(:action_view) do
        module ActionView::Helpers::TranslationHelper # rubocop:disable Lint/ConstantDefinitionInBlock
          alias_method :original_translate, :translate

          def translate(key, **options)
            value = original_translate(key, **options)

            is_missing_translation = value.include?('class="translation_missing"')
            if value.is_a?(String) && is_missing_translation
              value = extract_inner_content(value)
            end

            if moirai_edit_enabled?
              @key_finder ||= Moirai::KeyFinder.new

              render(partial: "moirai/translation_files/form",
                locals: {key: scope_key_by_partial(key),
                         locale: I18n.locale,
                         is_missing_translation: is_missing_translation,
                         value: value})
            else
              value
            end
          end

          alias_method :t, :translate

          def moirai_edit_enabled?
            params[:moirai] == "true"
          end

          private

          def extract_inner_content(html)
            match = html.match(/<[^>]+>([^<]*)<\/[^>]+>/)
            match ? match[1] : nil
          end
        end
      end
    end
  end
end
