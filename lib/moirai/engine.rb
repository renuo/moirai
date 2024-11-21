# frozen_string_literal: true

module Moirai
  class Engine < ::Rails::Engine
    isolate_namespace Moirai

    config.generators do |generator|
      generator.orm :active_record
    end

    config.after_initialize do
      I18n.original_backend = I18n.backend
      if ActiveRecord::Base.connection.data_source_exists?("moirai_translations") || ENV["RAILS_ENV"] == "test"
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

            if moirai_edit_enabled?
              @key_finder ||= Moirai::KeyFinder.new

              render(partial: "moirai/translation_files/form",
                locals: {key: scope_key_by_partial(key),
                         locale: I18n.locale,
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
