require "rails/generators"
require "rails/generators/migration"

module Moirai
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_migration
        invoke "moirai:migration"
      end

      def setup_javascript
        if using_importmap?
          say "Pin moirai"
          string_to_be_added = "pin \"controllers/moirai_translation_controller\", to: \"moirai_translation_controller.js\""
          say %(Appending: #{string_to_be_added})
          append_to_file "config/importmap.rb", %(#{string_to_be_added}\n)
        elsif using_js_bundling?
          append_path = "app/javascript/controllers/moirai_translation_controller.js"
          say "Copying Moirai Stimulus controller in #{append_path}"
          copy_file "../../../../app/assets/javascripts/moirai_translation_controller.js", append_path
          rails_command "stimulus:manifest:update"
        end
      end

      def using_js_bundling?
        Rails.root.join("app/javascript/controllers").exist?
      end

      def mount_engine
        route "mount Moirai::Engine, at: Moirai.configuration.root_path, as: 'moirai'"
      end

      def add_initializer
        say "Copying Moirai initializer"
        template "initializers/moirai.tt", "config/initializers/moirai.rb"
      end

      private

      def using_importmap?
        Rails.root.join("config/importmap.rb").exist?
      end
    end
  end
end
