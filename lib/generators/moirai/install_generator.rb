require "rails/generators"
require "rails/generators/migration"

module Moirai
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_migration
        invoke "moirai:migration"
      end
    end
  end
end