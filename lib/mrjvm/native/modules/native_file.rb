module NativeFile
  def read_line
    instance_pointer = frame.locals[0]
    object_id = instance_pointer.value
    line = file_manager.read_line(object_id)
    if line.nil?
      Heap::StackVariable.new(Heap::VARIABLE_NILL, nil)
    else
      object_heap.create_string_object(line, class_heap)
    end
  end

  def read_file
    instance_pointer = frame.locals[0]
    object_id = instance_pointer.value
    line = file_manager.read_file(object_id)
    if line.nil?
      Heap::StackVariable.new(Heap::VARIABLE_NILL, nil)
    else
      object_heap.create_string_object(line, class_heap)
    end
  end

  def write
    instance_pointer = frame.locals[0]
    text_pointer = frame.locals[1]
    char_array_pointer = object_heap.get_object(text_pointer).variables[3]
    text_to_write = char_array_to_string(char_array_pointer)
    object_id = instance_pointer.value
    line = file_manager.write(object_id, text_to_write)
    object_heap.create_string_object(line, class_heap)
    Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
  end

  def write_line
    instance_pointer = frame.locals[0]
    text_pointer = frame.locals[1]
    char_array_pointer = object_heap.get_object(text_pointer).variables[3]
    text_to_write = char_array_to_string(char_array_pointer)
    object_id = instance_pointer.value
    line = file_manager.write_line(object_id, text_to_write)
    object_heap.create_string_object(line, class_heap)
    Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
  end

  def open_read
    instance_pointer = frame.locals[0]
    object_id = instance_pointer.value
    filename_pointer = frame.locals[1]
    char_array_pointer = object_heap.get_object(filename_pointer).variables[3]
    filename = char_array_to_string(char_array_pointer)
    file_manager.open(object_id, filename, 'r')
    Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
  end

  def open_write
    instance_pointer = frame.locals[0]
    object_id = instance_pointer.value
    filename_pointer = frame.locals[1]
    char_array_pointer = object_heap.get_object(filename_pointer).variables[3]
    filename = char_array_to_string(char_array_pointer)
    file_manager.open(object_id, filename, 'w')
    Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
  end

  def close_read
    instance_pointer = frame.locals[0]
    object_id = instance_pointer.value
    file_manager.close(object_id, 'r')
    Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
  end

  def close_write
    instance_pointer = frame.locals[0]
    object_id = instance_pointer.value
    file_manager.close(object_id, 'w')
    Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
  end
end