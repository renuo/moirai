module Moirai
  class TranslationUpdater
    attr_reader :translation

    def initialize(translation)
      @translation = translation
    end

    def update_translation
      return unless File.exist?(translation.file_path)

      lines = File.readlines(translation.file_path)
      updated_lines = lines.map { |line| update_line(line) }

      File.write(translation.file_path, updated_lines.join)

      true
    end

    private

    def update_line(line)
      # Add root node (locale) to the key
      root_key = "#{locale_root}.#{translation.key}"

      # Check if the line starts with the root key and replace the value if it matches
      if line.strip.start_with?(root_key)
        # Extract the indentation level for pretty formatting
        indent = line[/\A\s*/]
        return "#{indent}#{root_key}: #{translation.value.strip}\n"
      end

      line
    end

    # Get the locale root node (based on file path)
    def locale_root
      # Assume the root node is the first part of the locale file
      translation.file_path.match(/\/([a-z]{2})\.yml$/)[1]
    end
  end
end
