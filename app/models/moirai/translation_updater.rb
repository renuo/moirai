module Moirai
  class TranslationUpdater
    def call
      translations = Moirai::Translation.all
      translations.map(&:file_path).uniq.each do |file_path|
        @file_path = file_path
        @translations = translations.select { |t| t.file_path == file_path }

        yaml = YAML.load_file(@file_path)

        @translations.each do |translation|
          keys = translation.key.split(".")

          keys.inject(yaml) do |node, key|
            node[key] ||= {}
          end[keys.last] = translation.value
        end

        pp yaml.to_yaml
      end
    end

    def update_translation_file(file_path)
      translations = Moirai::Translation.where(file_path: file_path)


      yaml.to_yaml
    end
  end
end
