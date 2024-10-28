module Moirai
  class TranslationDumper
    # @return Array[Hash]
    def call
      project_root = Rails.root
      Moirai::Translation.pluck(:file_path).uniq.map do |file_path|
        absolute_file_path = File.expand_path(file_path, project_root)

        # skip file paths that don't belong to the project
        next unless absolute_file_path.start_with?(project_root.to_s)

        updated_file_contents = get_updated_file_contents(file_path)
        {
          file_path: Pathname.new(file_path).relative_path_from(project_root),
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
