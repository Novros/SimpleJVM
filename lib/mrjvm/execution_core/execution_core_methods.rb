module ExecutionCoreMethods
  def execute_invoke(frame_stack, static)
    method_index = frame_stack[fp].method[:attributes][0][:code][frame_stack[fp].pc+1, 2].join('').to_i(16)
    method_constant = frame_stack[fp].java_class.constant_pool[method_index-1]
    name_and_type_index = method_constant[:name_and_type_index]

    class_index = method_constant[:class_index]
    class_constant = frame_stack[fp].java_class.constant_pool[class_index-1]
    class_name = frame_stack[fp].java_class.get_from_constant_pool(class_constant[:name_index])

    method_constant = frame_stack[fp].java_class.constant_pool[name_and_type_index-1]
    method_name = frame_stack[fp].java_class.get_from_constant_pool(method_constant[:name_index])
    method_descriptor = frame_stack[fp].java_class.get_from_constant_pool(method_constant[:descriptor_index])

    java_class = class_heap.get_class(class_name)
    method_index = java_class.get_method_index(method_name, method_descriptor, static)
    method = java_class.methods[method_index]

    MRjvm.debug('Invoking method: ' << method_name << ', descriptor: ' << method_descriptor)

    parameters_count = get_method_parameters_count(method_descriptor)
    parameters_count -= 1 if static
    # Prepare frame for invoked method
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SUPER) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class.get_super_class, method, parameters_count)
    elsif (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_native_method(java_class, method)
    else
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class, method, parameters_count)
    end
    frame_stack[fp+1].sp = frame_stack[fp].sp
    for i in 0..parameters_count do
      frame_stack[fp+1].locals[i] = frame_stack[fp].stack[frame_stack[fp].sp-parameters_count+i]
    end
    MRjvm::MRjvm.mutex.synchronize do
      @fp += 1
    end
    return_value = execute(frame_stack)
    MRjvm::MRjvm.mutex.synchronize do
      @fp -= 1
    end

    frame_stack[fp].sp -= parameters_count
    frame_stack[fp].stack[frame_stack[fp].sp] = return_value # At top should be return value
    frame_stack[fp].sp -= 1 if method_descriptor.include? ')V' # If it is void
  end

  def execute_dynamic_method(frame_stack)
    # TODO Implements
    raise StandardError, 'Dynamic methods not implemented.'
  end

  def execute_interface_method(frame_stack)
    # TODO Implements
    raise StandardError, 'Interface methods not implemented.'
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
        if method_descriptor[i] == 'L'
          i += 1 while method_descriptor[i] != ';'
        end
      elsif method_descriptor[i] == ')'
        break
      end
      i += 1
    end
    MRjvm.debug('[METHOD][COUNT] ' << count.to_s)
    count
  end
end