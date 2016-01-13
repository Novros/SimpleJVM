require 'mrjvm/version'
require 'mrjvm/class_file/java_class'

module MRjvm
  DEBUG_STRING = '[DEBUG] '

  ##
  # Debug function if DEBUG is true.
  def self::debug(string)
    puts DEBUG_STRING + string + "\n" if DEBUG
  end

  class MrjvmNative
    def initialize (class_file_path)
      reader = ClassFileReader.new(class_file_path)
      reader.parse_content
      @java_class = reader.class_file
    end

    def run
      methods = []
      @java_class.methods.each do |method|
        if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
          methods << method
        end
      end

      puts methods

    end
  end
end