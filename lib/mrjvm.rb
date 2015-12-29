require 'nrjvm/version'
require 'nrjvm/class_file/java_class'

module MRjvm

  DEBUG_STRING = '[DEBUG] '

  def self::debug(string)
    puts DEBUG_STRING + string + "\n" if DEBUG
  end

  class MRjvm
    def initialize
    end

    def run(file)
      reader = ClassFileReader.new(file)
      reader.parse_content
      puts reader.class_file
    end
  end
end
