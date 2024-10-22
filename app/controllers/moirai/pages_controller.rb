# frozen_string_literal: true

module Moirai
  class PagesController < ApplicationController
    def index
      i18n_file_paths = I18n.load_path
      file_contents = i18n_file_paths.map { |path| [path, parse_file(path)] }.to_h
      render json: file_contents
    end

    private

    def parse_file(path)
      is_yml_path = path.end_with?(".yml") || path.end_with?(".yaml")
      return unless is_yml_path
      YAML.load_file(path)
    end
  end
end
