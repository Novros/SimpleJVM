require_relative '../class_file/java_class'
require_relative '../class_file/reader/class_file_reader'

module Heap
  class ClassLoaderError < StandardError
  end

  ##
  # This heap contains loaded classes.
  class ClassHeap
    def initialize
      @class_map = {}
    end

    def add_class(java_class)
      MRjvm.debug('Adding class to class heap. ' << java_class.this_class_str)

      @class_map[java_class.this_class_str.to_sym] = java_class
    end

    def get_class(class_name)
      MRjvm.debug('Getting class from heap. ' << class_name)

      java_class = @class_map[class_name.to_sym]
      if java_class.nil?
        load_class(class_name)
      else
        java_class
      end
    end

    def load_class(class_name)
      MRjvm.debug('Loading class: ' << class_name)

      class_file_name = class_name + '.class'

      # First try load from standard library
      path = get_path_from_std(class_file_name)
      # If not exists in standard library, load from project
      path = get_relative_path(class_file_name) unless File.file? path
      # If class does not exist throw error.
      fail ClassLoaderError, "Could not load class #{class_file_name}" unless File.file? path

      reader = ClassFileReader.new(path)
      reader.parse_content
      java_class = reader.class_file
      java_class.class_heap = self
      initialize_class_variables(java_class)
      add_class(java_class)

      MRjvm.debug('' << java_class.to_s)

      java_class
    end

    def load_class_from_file(file)
      MRjvm.debug('Loading class from file: ' << file)

      reader = ClassFileReader.new(file)
      reader.parse_content
      java_class = reader.class_file
      java_class.class_heap = self
      initialize_class_variables(java_class)
      add_class(java_class)

      save_project_path(file, java_class)

      MRjvm.debug('' << java_class.to_s)

      java_class
    end

    def save_project_path(file, java_class)
      @project_path = File.expand_path(File.dirname(file))
      count = java_class.this_class_str.count('/')
      count.times do
        @project_path << '/..'
      end
    end

    def initialize_class_variables(java_class)
      count = 0
      java_class.fields.each do |field|
        count += 1 if (field[:access_flags].to_i(16) & AccessFlagsReader::ACC_STATIC) != 0
      end
      java_class.static_variables = Array.new(count, nil)
    end

    def get_relative_path(class_name)
      "#{@project_path}/#{class_name}"
    end

    def get_path_from_std(class_name)
      '' + File.expand_path(File.dirname(__FILE__)) + "/../../std/class/#{class_name}"
    end

    def to_s
      string = "Class heap\n"
      @class_map.each do |item|
        string << "[DEBUG] \t#{item[0]} => #{item[1].this_class_str}\n"
      end
      string << '[DEBUG]'
      string
    end
  end
end
