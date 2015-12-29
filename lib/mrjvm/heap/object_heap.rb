require_relative 'types'

module Heap
  ##
  # This class is for
  class ObjectHeap

    def initialize
      @object_map = {}
      @object_id = 1
    end

    def create_object(java_class)
      object = Object.new
      object.heap_id = @object_id
      object.type = 0
      @object_map[object.heap_id.to_sym] = object
      @object_id += 1
      object
    end

    def create_string_object

    end

    def create_object_array

    end

    def get_object

    end

    def create_new_array

    end
  end
end