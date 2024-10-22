module Moirai
  class TranslationDumper
    def call
      updated_translation_file_paths = Moirai::Translation.pluck(:file_path).uniq

      updated_translation_file_paths.map do |file_path|
        updated_file_contents = get_updated_file_contents(file_path)
        {
          file_path: file_path,
          content: updated_file_contents
        }
      end
    end

    def get_updated_file_contents(file_path)
      translations = Moirai::Translation.where(file_path: file_path)

      yaml = YAML.load_file(file_path)

      translations.each do |translation|
        keys = translation.key.split(".")

        keys.inject(yaml) do |node, key|
          node[key] ||= {}
        end[keys.last] = translation.value
      end

      yaml.to_yaml
    end
  end
end
