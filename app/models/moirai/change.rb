# frozen_string_literal: true

# Prepares a certain file to be changefd in a Pull Request.
# It takes care of adjusting the file_path and content
module Moirai
  class Change
    attr_reader :file_path, :content

    def initialize(file_path, content)
      @file_path = file_path
      @file_path = file_path.to_s.start_with?("./") ? file_path : "./#{file_path}"
      @content = content.to_s.end_with?("\n") ? content : "#{content}\n"
    end
  end
end
