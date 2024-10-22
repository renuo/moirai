# frozen_string_literal: true

module Moirai
  module ApplicationHelper
    def shorten_path(path)
      path.gsub(Rails.root.to_s, ".")
    end
  end
end
