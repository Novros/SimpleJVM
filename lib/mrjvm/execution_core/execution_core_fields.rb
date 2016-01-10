module ExecutionCoreFields
  def load_constant(java_class, index)
    MRjvm.debug('Loading constant from pool, class: ' << java_class.this_class_str << ', index: ' << index.to_s)

    constant = java_class.constant_pool[index-1]

    case constant[:tag]
      when TagReader::CONSTANT_INTEGER
        value = Heap::StackVariable.new(Heap::VARIABLE_INT, java_class.get_from_constant_pool(constant[:value_index]))
      when TagReader::CONSTANT_LONG
        value = Heap::StackVariable.new(Heap::VARIABLE_LONG, constant[:value])
      when TagReader::CONSTANT_FLOAT
        value = Heap::StackVariable.new(Heap::VARIABLE_FLOAT, constant[:value])
      when TagReader::CONSTANT_DOUBLE
        value = Heap::StackVariable.new(Heap::VARIABLE_DOUBLE, constant[:value])
      when TagReader::CONSTANT_STRING
        value = object_heap.create_string_object(java_class.get_from_constant_pool(constant[:string_index]), class_heap)
      else
        raise StandardError, '[ERROR] load_constant ' << constant[:tag].to_s
    end
    value
  end

  def put_field(frame)
    index = get_method_byte_code(frame)[frame.pc+1, 2].join.to_i(16) - 1
    object_id = frame.stack[frame.sp - 1]
    value = frame.stack[frame.sp]

    MRjvm.debug("Putting value into field of object: #{object_id} on index: #{index} with value: #{value}.")

    var_list = object_heap.get_object(object_id).variables
    var_list[index] = value
    frame.sp -= 2
  end

  def get_field(frame)
    index = get_method_byte_code(frame)[frame.pc+1, 2].join.to_i(16) - 1
    object_id = frame.stack[frame.sp]

    MRjvm.debug("Reading field from object: #{object_id} on index: #{index}.")

    var_list = object_heap.get_object(object_id).variables
    frame.stack[frame.sp] = var_list[index]
  end

  def put_static_field(frame)
    value = frame.stack[frame.sp]
    frame.sp -= 1
    index = get_method_byte_code(frame)[frame.pc+1, 2].join.to_i(16) - 1
    frame.java_class.put_static_field(index, value)

    MRjvm.debug("Putting value into static field of class: #{frame.java_class.this_class_str}, #{index}, #{value}.")
  end

  def get_static_field(frame)
    index = get_method_byte_code(frame)[frame.pc+1, 2].join.to_i(16) - 1
    value = frame.java_class.get_static_field(index, object_heap)
    frame.sp += 1
    frame.stack[frame.sp] = value

    MRjvm.debug("Reading value from static field of class: #{frame.java_class.this_class_str}, #{index}.")
  end
end