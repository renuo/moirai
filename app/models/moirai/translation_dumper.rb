module Moirai
  class TranslationDumper
    def call
      Moirai::Translation.pluck(:file_path).uniq.map do |file_path|
        updated_file_contents = get_updated_file_contents(file_path)
        {
          file_path: file_path,
          content: updated_file_contents
        }
      end
    end

    private

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
