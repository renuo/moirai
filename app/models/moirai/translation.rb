# frozen_string_literal: true

module Moirai
  class Translation < Moirai::ApplicationRecord
    validates_presence_of :key, :locale, :file_path
    validate :file_path_must_exist

    private

    def file_path_must_exist
      errors.add(:file_path, "must exist") unless file_path && File.exist?(file_path)
    end
  end
end
