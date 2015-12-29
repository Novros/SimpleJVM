require 'nrjvm/version'
require 'nrjvm/class_file/java_class'

module Nrjvm

  DEBUG_STRING = '[DEBUG] '

  def self::debug(string)
    puts DEBUG_STRING + string + "\n" if DEBUG
  end

  class Nrjvm
    def initialize
    end

    def run(file)
      java_class = ClassFile::JavaClass.new
      java_class.load_class_file_from_file(file)
    end
  end
end
