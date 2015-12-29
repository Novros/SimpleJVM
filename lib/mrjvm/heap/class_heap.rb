require_relative '../class_file/class_file'
require_relative '../class_file/reader/class_file_reader'

module Heap
  ##
  # This heap contains loaded classes.
  class ClassHeap

    def initialize
      @class_map = {}
    end

    def add_class(java_class)
      @class_map[java_class.this_class_str.to_sym] = java_class
    end

    def get_class(class_name)
      java_class = @class_map[class_name.to_sym]
      if java_class.nil?
        load_class(class_name)
      else
        java_class
      end
    end

    def load_class(class_name)
      path = class_name + '.class'
      # TODO: Get absolute or relative path.
      reader = ClassFileReader.new(path)
      reader.parse_content
      java_class = reader.class_file
      java_class.class_heap = self
      add_class(java_class)
      java_class
    end
  end
end