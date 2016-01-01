module Heap

  class Object
    attr_accessor :heap_id, :type, :variables
  end

  class ObjectPointer
    attr_accessor :heap_id

    def initialize(heap_id)
      @heap_id = heap_id
    end

    def to_s
      "obj_p:#{heap_id}"
    end
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
      object.type = java_class
      object.variables = Array.new(java_class.fields_count, nil)
      @object_map[object.heap_id.to_s.to_sym] = object
      @object_id += 1
      ObjectPointer.new(@object_id-1)
    end

    def create_string_object (string, class_heap)
      MRjvm::debug('Creating string object for string: ' << string)

      java_class = class_heap.get_class('java/lang/String')
      object_pointer = create_object(java_class)
      object = get_object(object_pointer)
      object.variables[0] = string
      object_pointer
    end

    def get_object(object_pointer)
      MRjvm::debug('Reading object from object heap with id:' << object_pointer.heap_id.to_s)

      @object_map[object_pointer.heap_id.to_s.to_sym]
    end

    def create_new_array(count)
      MRjvm::debug('Creating array for count: ' << count)

      object = Object.new
      object.heap_id = @object_id
      object.type = 'Array'
      object.variables = Array.new(count, nil)
      @object_map[object.heap_id.to_s.to_sym] = object
      @object_id += 1
      ObjectPointer.new(@object_id-1)
    end

    def to_s
      string = "Object heap\n"
      @object_map.each do |item|
        string << "[DEBUG] \t#{item[0]} => #{item[1].type.this_class_str}\n"
      end
      string << '[DEBUG]'
      string
    end

  end
end