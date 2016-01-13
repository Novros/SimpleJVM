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
      methods = ''
      @java_class.methods.each do |method|
        if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
          methods << method_string(method) << "\n\n"
        end
      end
      @file = File.open(@java_class.this_class_str + '.h', 'w')
      @file.write(methods)
    end

    def method_string (method)
      name = 'Java_' + @java_class.this_class_str + '_'
      method_name = @java_class.constant_pool[method[:name_index] - 1][:bytes]
      descriptor = @java_class.constant_pool[method[:descriptor_index] - 1][:bytes]
      string = get_method_comment(method_name, @java_class.this_class_str, descriptor)
      arguments = get_arguments_type(descriptor)
      return_type = get_return_type(descriptor)
      string << return_type << ' ' << name << method_name << '('
      arguments.each do |arg|
        string << arg << ', '
      end
      (arguments.size == 0) ? string + ');' : string.chop.chop + ');'
    end

    def get_method_comment(name, class_name, descriptor)
      "/*\n * Class:\t#{class_name}\n * method:\t#{name}\n * descriptor:\t#{descriptor}\n */\n"
    end

    def get_return_type(descriptor)
      for i in (1..descriptor.size)
        if descriptor[i - 1] == ')'
          return get_method_type(descriptor[i, descriptor.size-i])
        end
      end
    end

    def get_arguments_type(descriptor)
      args = []
      for i in (1..descriptor.size)
        break if descriptor[i] == ')'
        args << get_method_type(descriptor[i, 1])
      end
      args
    end

    def get_method_type(type)
      str = case type[0]
              when 'B', 'C'
                'char'
              when 'S'
                'short'
              when 'I'
                'int'
              when 'J'
                'long'
              when 'F'
                'float'
              when 'D'
                'double'
              when '['
                get_method_type(type[1]) + '*'
              when 'V'
                'void'
              when 'L'
                raise StandardError, 'Objects in native are not supported.'
              else
                nil
            end
      str
    end
  end
end