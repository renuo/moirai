module Moirai
  class Configuration
    attr_accessor :root_path

    def initialize
      @root_path = '/moirai'
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end
end
