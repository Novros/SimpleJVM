require_relative 'types'

module Heap

  class Object
    attr_accessor :heap_id, :type, :variables
  end

  ##
  # This heap is for created objects.
  class ObjectHeap

    def initialize
      @object_map = {}
      @object_id = 1
    end

    def create_object(java_class)
      MRjvm::debug('Creating object for class: ' << java_class.this_class_str)

      object = Object.new
      object.heap_id = @object_id
      object.type = 0
      object.variables = Array[java_class.fields_count+1, nil] # +1 - for class
      object.variables[0] = java_class
      @object_map[object.heap_id.to_s.to_sym] = object
      @object_id += 1
      object.heap_id
    end

    def create_string_object (string, class_heap)
      MRjvm::debug('Creating string object for string: ' << string)

      java_class = class_heap.get_class('java/lang/String')
      heap_id = create_object(java_class)
      object = get_object(heap_id)
      object.variables[1] = string
      heap_id
    end

    def create_object_array(java_class, count)
      # TODO Implement
    end

    def get_object(heap_id)
      MRjvm::debug('Reading object from object heap with id:' << heap_id.to_s)

      @object_map[heap_id.to_s.to_sym]
    end

    def create_new_array
      # TODO Implement
    end

    def to_s
      string = "Object heap\n"
      @object_map.each do |item|
        string << "[DEBUG] \t#{item[0]} => #{item[1].variables[0].this_class_str}\n"
      end
      string << '[DEBUG]'
      string
    end

  end
end