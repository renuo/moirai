module Moirai
  class TranslationDumper
    def call
      project_root = Rails.root.to_s
      Moirai::Translation.pluck(:file_path).uniq.map do |file_path|
        absolute_file_path = File.expand_path(file_path, project_root)
        next unless absolute_file_path.start_with?(project_root)

        updated_file_contents = get_updated_file_contents(file_path)
        {
          file_path: file_path.sub("#{project_root}", "."),
          content: updated_file_contents
        }
      end.compact
    end

    private

    def get_updated_file_contents(file_path)
      translations = Moirai::Translation.where(file_path: file_path)

      yaml = YAML.load_file(file_path)

      translations.each do |translation|
        keys = [translation.locale] + translation.key.split(".")

        keys.inject(yaml) do |node, key|
          node[key] ||= {}
        end[keys.last] = translation.value
      end

      yaml.to_yaml
    end
  end
end
