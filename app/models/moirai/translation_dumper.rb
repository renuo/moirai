module Moirai
  class TranslationDumper
    def initialize
      @key_finder = KeyFinder.new
    end

    # @return Array[Moirai::Change]
    def call
      translations_by_file_path = group_translations_by_file_path
      changes = []
      translations_by_file_path.each do |file_path, translations|
        relative_file_path = Pathname.new(file_path).relative_path_from(Rails.root)
        changes << Change.new(relative_file_path, get_updated_file_contents(file_path, translations))
      end
      changes
    end

    def best_file_path_for(key, locale)
      file_paths = @key_finder.file_paths_for(key, locale: locale)
      file_paths.filter! { |p| p.start_with?(Rails.root.to_s) }
      if file_paths.any?
        file_paths.first
      elsif key.split(".").size > 1
        parent_key = key.split(".")[0..-2].join(".")
        best_file_path_for(parent_key, locale)
      else
        "./config/locales/#{locale}.yml"
      end
    end

    private

    def group_translations_by_file_path
      translations_grouped_by_file_path = {}
      Moirai::Translation.order(created_at: :asc).each do |translation|
        file_path = best_file_path_for(translation.key, translation.locale)
        absolute_file_path = File.expand_path(file_path, Rails.root)

        # skip file paths that don't belong to the project
        next unless absolute_file_path.to_s.start_with?(Rails.root.to_s)

        translations_grouped_by_file_path[absolute_file_path] ||= []
        translations_grouped_by_file_path[absolute_file_path] << translation
      end
      translations_grouped_by_file_path
    end

    def get_updated_file_contents(file_path, translations)
      yaml = YAML.load_file(file_path)

      translations.each do |translation|
        keys = [translation.locale] + translation.key.split(".")

        node = yaml

        (0...keys.size).each do |i|
          key = keys[i]
          if i == keys.size - 1
            node[key] = translation.value
          else
            node[key] ||= {}
            node = node[key]
          end
        end
      end

      yaml.to_yaml
    end
  end
end
