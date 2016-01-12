module NativePrint
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
end