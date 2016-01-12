module NativeStringBuilder
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
end