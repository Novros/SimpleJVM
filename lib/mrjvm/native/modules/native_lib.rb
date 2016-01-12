module NativeLib
  def load_native_library
    stack_variable = object_heap.get_object(frame.locals[0])
    string = char_array_to_string(stack_variable.variables[3])
    class_heap.load_native_library(string, frame.java_class)
    Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
  end
end