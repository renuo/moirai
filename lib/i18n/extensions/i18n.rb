# frozen_string_literal: true

module I18n
  class << self
    attr_accessor :original_backend
  end

  def self.translate_without_moirai(key, locale, **)
    raise "Original backend is not set" unless original_backend

    original_backend.translate(locale, key, **)
  end
end