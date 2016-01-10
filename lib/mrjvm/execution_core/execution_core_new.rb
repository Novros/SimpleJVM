module ExecutionCoreNew
  def execute_new(frame)
    frame.sp += 1
    byte_code = get_method_byte_code(frame)
    index = byte_code[frame.pc+1, 2].join('').to_i(16)

    MRjvm.debug('Executed new on class index: ' << index.to_s << ' in class ' << frame.java_class.this_class_str)

    frame.stack[frame.sp] = frame.java_class.create_object(index, object_heap)
  end

  def execute_new_array(frame)
    type = get_method_byte_code(frame)[frame.pc+1].to_i(16)
    count = frame.stack[frame.sp]

    MRjvm.debug("Creating new array, type: #{type}, count: #{count}.")

    frame.stack[frame.sp] = object_heap.create_new_array(type, count)
  end

  def execute_a_new_array(frame)
    index = get_method_byte_code(frame)[frame.pc+1, 2].join('').to_i(16)
    class_name = frame.java_class.get_from_constant_pool(frame.java_class.constant_pool[index-1][:name_index])
    count = frame.stack[frame.sp]

    MRjvm.debug("Creating new array, type: #{class_name}, count: #{count}.")

    frame.stack[frame.sp] = object_heap.create_new_array(class_name, count)
  end

  def execute_new_a_multi_array(frame)
    # TODO Check if works
    index = get_method_byte_code(frame)[frame.pc+1, 2].join('').to_i(16)
    class_name = frame.java_class.get_from_constant_pool(frame.java_class.constant_pool[index-1][:name_index])
    dimensions = get_method_byte_code(frame)[frame.pc+1].to_i(16)
    count = frame.stack[frame.sp-dimensions]
    array_pointer = object_heap.create_new_array(class_name, count)
    array = object_heap.get_object(array_pointer)

    MRjvm.debug("Creating new array, type: #{class_name}, count: #{count}, dimensions: #{dimensions}.")

    (1...dimensions).each do |i|
      count = frame.stack[frame.sp-dimensions+i]
      array.variables[i] = Array.new(count, nil)
    end
    frame.sp -= dimensions
    frame.stack[frame.sp] = array_pointer
  end
end