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
  end
end
