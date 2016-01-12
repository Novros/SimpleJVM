require_relative 'stack_variable'
require_relative '../synchronization/synchronized_hash'
require_relative '../synchronization/synchronized_array'

module Heap
  # This class is stored on object heap.
  class Object
    attr_accessor :heap_id, :type, :variables
  end

  ##
  # This heap is for created objects.
  class ObjectHeap
    def initialize
      @object_map = SynchronizedHash.new
      @object_id = 1
    end

    def create_object(java_class)
      MRjvm.debug('Creating object for class: ' << java_class.this_class_str)

      object = Object.new
      object.heap_id = @object_id
      object.type = java_class
      object.variables = SynchronizedArray.new(java_class.fields_count, nil)
      @object_map[object.heap_id.to_s.to_sym] = object
      @object_id += 1
      StackVariable.new(VARIABLE_OBJECT, @object_id - 1)
    end

    def create_string_object(text, class_heap)
      MRjvm.debug('Creating string object for string: ' << text)

      java_class = class_heap.get_class('java/lang/String')
      object_pointer = create_object(java_class)
      object = get_object(object_pointer)

      # text, text.value, get_object(text)
      if text.is_a? StackVariable
        if text.type == 8
          string = ''
          string_array = get_object(text).variables
          string_array.each do |char|
            string << char.chr
          end
        else
          string = text.value.to_s
        end
      else
        string = text.to_s
      end
      array_pointer = create_new_array(0, StackVariable.new(VARIABLE_INT, string.size))
      array = get_object(array_pointer)
      index = 0
      string.each_char do |char|
        array.variables[index] = StackVariable.new(VARIABLE_CHAR, char.ord)
        index += 1
      end
      object.variables[3] = array_pointer
      object.variables[1] = StackVariable.new(VARIABLE_INT, 0)
      object.variables[2] = StackVariable.new(VARIABLE_INT, string.size)
      StackVariable.new(VARIABLE_STRING, object.heap_id)
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
          if item[1].type.this_class_str.include? 'String'
            string << "[DEBUG] \t#{item[0]} => #{item[1].type.this_class_str} : #{item[1].variables[3]}\n"
          elsif item[1].type.this_class_str.include? 'Integer'
            string << "[DEBUG] \t#{item[0]} => #{item[1].type.this_class_str} : #{item[1].variables[1]}\n"
          else
            string << "[DEBUG] \t#{item[0]} => #{item[1].type.this_class_str}\n"
          end
        end
      end
      string << '[DEBUG]'
      string
    end

    # Iterate all objects in object heap
    def each(&block)
      @object_map.each(&block);
    end

    # Remove object from heap by object instance and heap id, withou synchronization
    def remove_object(object)
      @object_map.delete(object.heap_id.to_s.to_sym, false)
      MRjvm.debug('Removing object from object heap with id: ' << object.heap_id.to_s << '; heap size: ' << @object_map.size.to_s)
    end
  end
end
