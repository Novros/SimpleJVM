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
      object = Object.new
      object.heap_id = @object_id
      object.type = 0
      object.variables = Array[java_class.fields_count+1, nil] # +1 - for class
      object.variables[0] = java_class
      @object_map[object.heap_id.to_sym] = object
      @object_id += 1
      object
    end

    def create_string_object (string, class_heap)
      java_class = class_heap.get_class('java/lang/String')
      object = create_object(java_class)
      object.variables[1] = string
      object
    end

    def create_object_array(java_class, count)
      # TODO Implement
    end

    def get_object(object)
      @object_map[object.heap_id.to_sym]
    end

    def create_new_array
      # TODO Implement
    end
  end
end