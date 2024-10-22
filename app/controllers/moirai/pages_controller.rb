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
      yaml_content = YAML.load_file(path)
      flatten_hash(yaml_content)
    end

    def flatten_hash(hash, parent_key = '', result = {})
      hash.each do |key, value|
        new_key = parent_key.empty? ? key.to_s : "#{parent_key}.#{key}"
        if value.is_a?(Hash)
          flatten_hash(value, new_key, result)
        else
          result[new_key] = value
        end
      end
      result
    end
  end
end
