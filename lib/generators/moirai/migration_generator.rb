# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Moirai
  module Generators
    class MigrationGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def create_migration_file
        migration_template "create_moirai_translations.rb.erb", "db/migrate/create_moirai_translations.rb", migration_version: migration_version
      end

      def file_path_migration_file
        migration_template "make_moirai_translations_file_path_not_required.rb.erb", "db/migrate/make_moirai_translations_file_path_not_required.rb", migration_version: migration_version
      end

      private

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
