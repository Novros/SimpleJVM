require_relative 'stack_variable'

module Heap
  # This class is stored on object heap.
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
      MRjvm.debug('Creating object for class: ' << java_class.this_class_str)

      object = Object.new
      object.heap_id = @object_id
      object.type = java_class
      object.variables = Array.new(java_class.fields_count, nil)
      @object_map[object.heap_id.to_s.to_sym] = object
      @object_id += 1
      StackVariable.new(VARIABLE_OBJECT, @object_id - 1)
    end

    def create_string_object(string, class_heap)
      MRjvm.debug('Creating string object for string: ' << string)

      java_class = class_heap.get_class('java/lang/String')
      object_pointer = create_object(java_class)
      object = get_object(object_pointer)
      object.variables[0] = string
      object_pointer
    end

    def get_object(object_pointer)
      MRjvm.debug('Reading object from object heap with id:' << object_pointer.value.to_s)

      @object_map[object_pointer.value.to_s.to_sym]
    end

    def create_new_array(type, count)
      MRjvm.debug('Creating array for count: ' << count.value.to_s)

      object = Object.new
      object.heap_id = @object_id
      object.type = 'Array@' + type.to_s
      object.variables = Array.new(count.value, nil)
      @object_map[object.heap_id.to_s.to_sym] = object
      @object_id += 1
      StackVariable.new(VARIABLE_ARRAY, @object_id - 1)
    end

    def get_value_from_array(array_pointer, index)
      MRjvm.debug('Reading value from array with heap_id:' + array_pointer.value.to_s + ' on index: ' + index.to_s)

      array_object = @object_map[array_pointer.value.to_s.to_sym]
      array_object.variables[index]
    end

    def to_s
      string = "Object heap\n"
      @object_map.each do |item|
        if item[1].type.is_a? String
          string << "[DEBUG] \t#{item[0]} => #{item[1].type}\n"
        else
          string << "[DEBUG] \t#{item[0]} => #{item[1].type.this_class_str}\n"
        end
      end
      string << '[DEBUG]'
      string
    end
  end
end
