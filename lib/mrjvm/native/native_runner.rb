require_relative '../heap/object_heap'
require 'fiddle'
require 'fiddle/struct'
require 'fiddle/import'

module Native
  # This class run native methods from loaded shared libs.
  class NativeRunner
    attr_accessor :frame, :class_heap, :object_heap

    def run(method_signature, true_native)
      if true_native
        run_native(method_signature)
      else
        self.method(method_signature.to_sym).call
      end
    end

    def run_native(method_signature)
      at_index = method_signature.index('@')
      bracket_index = method_signature.index('(')
      class_name = method_signature[0, at_index]

      method_name = method_signature[at_index + 1, bracket_index - at_index - 1]
      method_name = 'Java_' + class_name + '_' + method_name
      method_descriptor = method_signature[bracket_index, method_signature.size - bracket_index]

      native_lib = class_heap.get_native_library(class_name)
      params_count = get_method_parameters_count(method_descriptor)

      args = [nil, nil]
      (1..params_count).each do |i|
        args << frame.locals[i]
      end

      arg_types = get_method_argument_types(method_descriptor)
      return_type = get_method_return_type(method_descriptor)
      return_stack_type = get_method_return_stack_type(method_descriptor)

      native_method = Fiddle::Function.new(native_lib[method_name], arg_types, return_type)
      args = prepare_args(args, native_method)
      return_value = native_method.call(*args)

      if return_type == Fiddle::TYPE_VOIDP
        raise StandardError, 'Native not support return pointer'
      end
      Heap::StackVariable.new(return_stack_type, return_value)
    end

    def prepare_args(args, native_method)
      new_args = []
      args.each do |arg|
        if arg.nil?
          new_args << nil
        else
          if arg.type == Heap::VARIABLE_ARRAY
            raise StandardError, 'Not support for native and array.'
          elsif arg.type == Heap::VARIABLE_STRING
            char_array_pointer = object_heap.get_object(arg).variables[3]
            char_array = object_heap.get_object(char_array_pointer).variables
            size = char_array.size()
            pointer = Fiddle::Pointer.malloc(size * Fiddle::SIZEOF_CHAR, native_method)
            char_array.each_with_index do |char, index|
              pointer[index] = char.value
            end
            new_args << pointer
          elsif arg.type == Heap::VARIABLE_OBJECT
            raise StandardError, 'Not support for native and object.'
          else
            new_args << arg.value
          end
        end
      end
      new_args
    end

    def native_print
      string_pointer = frame.locals[1]
      return if string_pointer.type == Heap::VARIABLE_NILL
      string = object_heap.get_object(string_pointer)
      char_array = object_heap.get_object(string.variables[3])
      text = ''
      char_array.variables.each do |char|
        text << char.value.chr unless char.nil?
      end
      puts text
      Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
    end

    def load_native_library
      stack_variable = object_heap.get_object(frame.locals[0])
      string = char_array_to_string(stack_variable.variables[3])
      class_heap.load_native_library(string, frame.java_class)
      Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
    end

    def string_builder_append_number
      string_builder_pointer = frame.locals[0]
      string_builder = object_heap.get_object(string_builder_pointer)
      string_builder.variables[0] = object_heap.create_string_object('', class_heap) if string_builder.variables[0].nil?
      string_builder_string = object_heap.get_object(string_builder.variables[0])
      char_array = object_heap.get_object(string_builder_string.variables[3]).variables

      value = frame.locals[1].value
      value.to_s.each_char do |char|
        char_array << Heap::StackVariable.new(Heap::VARIABLE_CHAR, char.ord)
      end

      string_builder_pointer
    end

    def string_builder_append_s
      string_builder_pointer = frame.locals[0]
      string_builder = object_heap.get_object(string_builder_pointer)
      string_builder.variables[0] = object_heap.create_string_object('', class_heap) if string_builder.variables[0].nil?
      string_builder_string = object_heap.get_object(string_builder.variables[0])
      char_array = object_heap.get_object(string_builder_string.variables[3]).variables

      string_pointer = frame.locals[1]
      string_object = object_heap.get_object(string_pointer)
      string_char_array = object_heap.get_object(string_object.variables[3]).variables

      string_char_array.each do |char|
        char_array << char
      end

      string_builder_pointer
    end

    def string_builder_to_string_string
      string_builder_pointer = frame.locals[0]
      string_builder = object_heap.get_object(string_builder_pointer)
      string_builder.variables[0] = object_heap.create_string_object('', class_heap) if string_builder.variables[0].nil?
      string_builder_string = object_heap.get_object(string_builder.variables[0])
      Heap::StackVariable.new(Heap::VARIABLE_STRING, string_builder_string.heap_id)
    end

    def char_array_to_string(array_pointer)
      array = object_heap.get_object(array_pointer)
      string = ''
      array.variables.each do |char|
        string << char.value.chr
      end
      string
    end

    def get_method_parameters_count(method_descriptor)
      count = 0
      i = 1
      while i < method_descriptor.size
        if method_descriptor[i] == 'B' || method_descriptor[i] == 'C' ||
            method_descriptor[i] == 'S' || method_descriptor[i] == 'I' ||
            method_descriptor[i] == 'J' || method_descriptor[i] == 'F' ||
            method_descriptor[i] == 'D' || method_descriptor[i] == 'L' ||
            method_descriptor[i] == '['
          count += 1
          if method_descriptor[i] == '['
            i += 1
            i += 1 if method_descriptor[i] != 'L'
          end
          if method_descriptor[i] == 'L'
            i += 1 until method_descriptor[i] == ';'
          end
        elsif method_descriptor[i] == ')'
          break
        end
        i += 1
      end
      count
    end

    def get_method_argument_types(method_descriptor)
      # First two types: JNIenv, jobject
      types = [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
      i = 1
      while i < method_descriptor.size
        break if method_descriptor[i] == ')'
        types << case method_descriptor[i]
                   when 'B', 'C'
                     Fiddle::TYPE_CHAR
                   when 'S'
                     Fiddle::TYPE_SHORT
                   when 'I'
                     Fiddle::TYPE_INT
                   when 'J'
                     Fiddle::TYPE_LONG
                   when 'F'
                     Fiddle::TYPE_FLOAT
                   when 'D'
                     Fiddle::TYPE_DOUBLE
                   when 'L'
                     i += 1 until method_descriptor[i] == ';'
                     Fiddle::TYPE_VOIDP
                   when '['
                     i += 1 until method_descriptor[i] == '['
                     i += 1
                     Fiddle::TYPE_VOIDP
                 end
        i += 1
      end
      types
    end

    def get_method_return_type(method_descriptor)
      type = nil
      for i in 1..method_descriptor.size
        if method_descriptor[i - 1] == ')'
          type = case method_descriptor[i]
                   when 'B', 'C'
                     Fiddle::TYPE_CHAR
                   when 'S'
                     Fiddle::TYPE_SHORT
                   when 'I'
                     Fiddle::TYPE_INT
                   when 'J'
                     Fiddle::TYPE_LONG
                   when 'F'
                     Fiddle::TYPE_FLOAT
                   when 'D'
                     Fiddle::TYPE_DOUBLE
                   when 'L', '['
                     Fiddle::TYPE_VOIDP
                   else
                     Fiddle::TYPE_VOID
                 end
          break
        end
      end
      type
    end

    def get_method_return_stack_type(method_descriptor)
      type = nil
      for i in 1..method_descriptor.size
        if method_descriptor[i - 1] == ')'
          type = case method_descriptor[i]
                   when 'B'
                     Heap::VARIABLE_BYTE
                   when 'C'
                     Heap::VARIABLE_CHAR
                   when 'S'
                     Heap::VARIABLE_SHORT
                   when 'I'
                     Heap::VARIABLE_INT
                   when 'J'
                     Heap::VARIABLE_LONG
                   when 'F'
                     Heap::VARIABLE_FLOAT
                   when 'D'
                     Heap::VARIABLE_DOUBLE
                   when 'L', '['
                     Heap::VARIABLE_OBJECT
                   else
                     Heap::VARIABLE_INT
                 end
          break
        end
      end
      type
    end
  end
end
