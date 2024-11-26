# frozen_string_literal: true

module Moirai
  class Engine < ::Rails::Engine
    isolate_namespace Moirai

    config.generators do |generator|
      generator.orm :active_record
    end

    config.moirai = ActiveSupport::OrderedOptions.new

    config.after_initialize do
      I18n.original_backend = I18n.backend
      table_created =
        begin
          (defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter) &&
            ActiveRecord::Base.connection.is_a?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)) ||
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

    initializer "rails_api_logger.config" do
      config.moirai.each do |name, value|
        Moirai.public_send(:"#{name}=", value)
      end
    end

    initializer "moirai.override_translation_helper" do
      ActiveSupport.on_load(:action_view) do
        require "moirai/translation_helper"
      end
    end
  end
end
