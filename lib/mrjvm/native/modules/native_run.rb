module NativeRun
  def run_native(method_signature)
    at_index = method_signature.index('@')
    bracket_index = method_signature.index('(')
    class_name = method_signature[0, at_index]

    method_name = method_signature[at_index + 1, bracket_index - at_index - 1]
    method_name = 'Java_' + class_name + '_' + method_name
    method_descriptor = method_signature[bracket_index, method_signature.size - bracket_index]

    native_lib = class_heap.get_native_library(class_name)
    params_count = get_method_parameters_count(method_descriptor)

    args = []
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
end