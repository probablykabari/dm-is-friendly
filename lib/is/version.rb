require "yaml"

module DataMapper
  module Is
    module Friendly
      VERSION = File.open(File.join(File.dirname(__FILE__), *%w[.. .. VERSION])) { |file| YAML.load(file) }
    end
  end
end
