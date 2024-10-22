module Moirai
  class TranslationDumper
    def call
      project_root = Rails.root.to_s
      Moirai::Translation.pluck(:file_path).uniq.map do |file_path|
        absolute_file_path = File.expand_path(file_path, project_root)
        next unless absolute_file_path.start_with?(project_root)

        updated_file_contents = get_updated_file_contents(file_path)
        {
          file_path: file_path.sub(project_root, "."),
          content: updated_file_contents
        }
      end.compact
    end

    private

    def get_updated_file_contents(file_path)
      translations = Moirai::Translation.where(file_path: file_path)

      original_yaml = YAML.load_file(file_path)

      translations.each do |translation|
        keys = [translation.locale] + translation.key.split(".")

        yaml = {}
        node = original_yaml

        for i in 0...keys.size
          key = keys[i]
          if i == keys.size - 1
            node[key] = translation.value
          else
            node[key] ||= {}
            node = node[key]
          end
        end
      end

      original_yaml.to_yaml
    end
  end
end
