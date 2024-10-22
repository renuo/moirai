require 'cgi'
require 'digest'

module Moirai
  class TranslationFilesController < ApplicationController
    before_action :load_file_paths, only: [:index, :show]
    before_action :generate_file_hashes, only: [:index, :show]

    def index
    end

    def show
      file_path = @file_hashes[params[:id]]
      decoded_path = CGI.unescape(file_path)
      @file_path = file_path
      @translation_keys = parse_file(decoded_path)
    end

    private

    def load_file_paths
      i18n_file_paths = I18n.load_path
      # @file_paths = i18n_file_paths.select { |path| (path.start_with? Rails.root.to_s) && path.end_with?(".yml", ".yaml") }
      @file_paths = i18n_file_paths.select { |path| path.end_with?(".yml", ".yaml") }
    end

    def generate_file_hashes
      @file_hashes = @file_paths.map { |path| [Digest::SHA256.hexdigest(path), path] }.to_h
    end

    def parse_file(path)
      yaml_content = YAML.load_file(path)
      root_key = yaml_content.keys.first
      flatten_hash(yaml_content[root_key])
    end

    def flatten_hash(hash, parent_key = "", result = {})
      hash.each do |key, value|
        new_key = parent_key.empty? ? key.to_s : "#{parent_key}.#{key}"
        case value
        when Hash
          flatten_hash(value, new_key, result)
        when Array
          value.each_with_index do |item, index|
            array_key = "#{new_key}.#{index}"
            if item.is_a?(Hash)
              flatten_hash(item, array_key, result)
            else
              result[array_key] = item
            end
          end
        else
          result[new_key] = value
        end
      end
      result
    end
  end
end
