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

      root_key = File.exist?(file_path) ? YAML.load_file(file_path).keys.first : I18n.locale

      yaml = File.exist?(file_path) ? YAML.load_file(file_path) : {root_key => {}}

      translations.each do |translation|
        keys = [root_key] + translation.key.split(".")

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
