# frozen_string_literal: true

module Moirai
  class Engine < ::Rails::Engine
    isolate_namespace Moirai

    config.generators do |generator|
      generator.orm :active_record
    end

    config.moirai = ActiveSupport::OrderedOptions.new

    def self.on_sqlite?
      defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter) &&
        ActiveRecord::Base.connection.is_a?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
    end

    def self.on_postgres?
      ActiveRecord::Base.connection.table_exists?("moirai_translations")
    end

    config.after_initialize do
      I18n.original_backend = I18n.backend
      table_created =
        begin
          on_sqlite? || on_postgres?
        rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
          false
        end
      if table_created
        I18n.backend = I18n::Backend::Chain.new(I18n::Backend::Moirai.new, I18n.backend)
        Rails.logger.info("moirai has been enabled.")
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

    initializer "moirai.assets" do |app|
      app.config.assets.precompile += %w[ moirai/application.css ]
    end
  end
end
