# frozen_string_literal: true

require "test_helper"

class MigrationGeneratorTest < Rails::Generators::TestCase
  tests Moirai::Generators::MigrationGenerator
  destination File.expand_path("tmp", __dir__)
  setup :prepare_destination

  test "migration file is created" do
    run_generator

    assert_migration "db/migrate/create_moirai_translations.rb"

    assert_file "db/migrate/create_moirai_translations.rb" do |content|
      assert_match(/class CreateMoiraiTranslations < ActiveRecord::Migration/, content)
      assert_match(/t.string :key, null: false/, content)
    end
  end
end
