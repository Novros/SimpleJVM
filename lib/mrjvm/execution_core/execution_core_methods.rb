module ExecutionCoreMethods
  # --------------------------------------------------------------------------------------------------------------------
  class AbstractMethodError < StandardError
  end

  # --------------------------------------------------------------------------------------------------------------------
  def execute_dynamic_method(frame_stack)
    actual_frame = frame_stack[fp]

    # Get method and class index
    method_index = get_method_byte_code(actual_frame)[actual_frame.pc+1, 2].join.to_i(16)
    method_constant = actual_frame.java_class.constant_pool[method_index-1]
    name_and_type_index = method_constant[:name_and_type_index]

    # Get class name
    class_index = method_constant[:class_index]
    class_constant = actual_frame.java_class.constant_pool[class_index-1]
    class_name = actual_frame.java_class.get_from_constant_pool(class_constant[:name_index])

    # Get method info
    method_constant = actual_frame.java_class.constant_pool[name_and_type_index-1]
    method_name = actual_frame.java_class.get_from_constant_pool(method_constant[:name_index])
    method_descriptor = actual_frame.java_class.get_from_constant_pool(method_constant[:descriptor_index])

    # Get class and method object
    java_class = class_heap.get_class(class_name)
    method_index = java_class.get_method_index(method_name, method_descriptor, false)
    method = java_class.methods[method_index]

    MRjvm.debug('Invoking dynamic method: ' << method_name << ', descriptor: ' << method_descriptor)

    # Get count of parameters
    parameters_count = get_method_parameters_count(method_descriptor)

    # Create frame for next method.
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SUPER) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class.get_super_class, method, parameters_count)
    elsif (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_native_method(java_class, method)
    else
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class, method, parameters_count)
    end

    # Copy parameters to locals
    # frame_stack[fp+1].sp = actual_frame.sp
    for i in 0..parameters_count do
      frame_stack[fp+1].locals[i] = actual_frame.stack[actual_frame.sp-parameters_count+i]
    end

    MRjvm::MRjvm.mutex.synchronize do
      @fp += 1
    end

    # Execute next method
    return_value = execute(frame_stack)

    MRjvm::MRjvm.mutex.synchronize do
      @fp -= 1
    end

    # Remove parameters and save return value.
    actual_frame.sp -= parameters_count # Remove method parameters.
    actual_frame.stack[actual_frame.sp] = return_value # At top should be return value
    actual_frame.sp -= 1 if method_descriptor.include? ')V' # If it is void
  end

  # --------------------------------------------------------------------------------------------------------------------
  def execute_interface_method(frame_stack)
    actual_frame = frame_stack[fp]

    # Get method and class indexes
    method_index = actual_frame.method[:attributes][0][:code][actual_frame.pc+1, 2].join.to_i(16)
    method_constant = actual_frame.java_class.constant_pool[method_index-1]
    name_and_type_index = method_constant[:name_and_type_index]

    # Get class info
    class_index = method_constant[:class_index]
    class_constant = actual_frame.java_class.constant_pool[class_index-1]
    class_name = actual_frame.java_class.get_from_constant_pool(class_constant[:name_index])

    # Get method info
    method_constant = actual_frame.java_class.constant_pool[name_and_type_index-1]
    method_name = actual_frame.java_class.get_from_constant_pool(method_constant[:name_index])
    method_descriptor = actual_frame.java_class.get_from_constant_pool(method_constant[:descriptor_index])

    MRjvm.debug('Invoking virtual method: ' << method_name << ', descriptor: ' << method_descriptor)

    # Get parameters count to get object ref
    parameters_count = get_method_parameters_count(method_descriptor)

    # Get object ref
    object_pointer = actual_frame.stack[actual_frame.sp - parameters_count]
    object = object_heap.get_object(object_pointer)

    # Get class and method
    java_class = get_virtual_method_class(object.type, method_name, method_descriptor)
    method = java_class.get_method(method_name, method_descriptor)

    # Prepare frame for invoked method
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SUPER) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class.get_super_class, method, parameters_count)
    elsif (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_native_method(java_class, method)
    else
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class, method, parameters_count)
    end

    # Copy parameters to locals
    # frame_stack[fp+1].sp = actual_frame.sp
    for i in 0..parameters_count do
      frame_stack[fp+1].locals[i] = actual_frame.stack[actual_frame.sp-parameters_count+i]
    end

    MRjvm::MRjvm.mutex.synchronize do
      @fp += 1
    end

    # Execute next method
    return_value = execute(frame_stack)

    MRjvm::MRjvm.mutex.synchronize do
      @fp -= 1
    end

    # Remove parameters from stack and store return value.
    actual_frame.sp -= parameters_count
    actual_frame.stack[actual_frame.sp] = return_value # At top should be return value
    actual_frame.sp -= 1 if method_descriptor.include? ')V' # If it is void
  end

  # --------------------------------------------------------------------------------------------------------------------
  def execute_special_method(frame_stack)
    actual_frame = frame_stack[fp]

    # Get method and class index
    method_index = actual_frame.method[:attributes][0][:code][actual_frame.pc+1, 2].join.to_i(16)
    method_constant = actual_frame.java_class.constant_pool[method_index-1]
    name_and_type_index = method_constant[:name_and_type_index]

    # Get class name
    class_index = method_constant[:class_index]
    class_constant = actual_frame.java_class.constant_pool[class_index-1]
    class_name = actual_frame.java_class.get_from_constant_pool(class_constant[:name_index])

    # Get method name and descriptor
    method_constant = actual_frame.java_class.constant_pool[name_and_type_index-1]
    method_name = actual_frame.java_class.get_from_constant_pool(method_constant[:name_index])
    method_descriptor = actual_frame.java_class.get_from_constant_pool(method_constant[:descriptor_index])

    # Get parameters count to get object ref
    parameters_count = get_method_parameters_count(method_descriptor)

    # Get object ref
    object_pointer = actual_frame.stack[actual_frame.sp - parameters_count]
    object = object_heap.get_object(object_pointer)

    # Get class and method object
    java_class = class_heap.get_class(class_name)
    method_index = java_class.get_method_index(method_name, method_descriptor, false)
    method = java_class.methods[method_index]

    # ------------------------------------------------------------------------------------------------------------------
    # TODO
    # If method is protected and it is a member of a superclass of the current class, and the method is not declared in
    # the same run-time package as the current class, then the class of object_ref must be either the current class or
    # a subclass of the current class.
    # ------------------------------------------------------------------------------------------------------------------

    # If i must look for another class method.
    actual_java_class = actual_frame.java_class
    if (actual_java_class.access_flags.to_i(16) & AccessFlagsReader::ACC_SUPER) != 0 &&
        actual_java_class.super_class_str == java_class.this_class_str &&
        method_name != '<init>'
      java_class = get_special_method_class(actual_java_class.get_super_class, method_name, method_descriptor)
      method = java_class.get_method(method_name, method_descriptor)
    end

    MRjvm.debug('Invoking special method: ' << method_name << ', descriptor: ' << method_descriptor)

    # Prepare frame for invoked method
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SUPER) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class.get_super_class, method, parameters_count)
    elsif (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_native_method(java_class, method)
    else
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class, method, parameters_count)
    end
    # frame_stack[fp+1].sp = actual_frame.sp
    for i in 0..parameters_count do
      frame_stack[fp+1].locals[i] = actual_frame.stack[actual_frame.sp-parameters_count+i]
    end
    MRjvm::MRjvm.mutex.synchronize do
      @fp += 1
    end
    return_value = execute(frame_stack)
    MRjvm::MRjvm.mutex.synchronize do
      @fp -= 1
    end

    actual_frame.sp -= parameters_count
    actual_frame.stack[actual_frame.sp] = return_value # At top should be return value
    actual_frame.sp -= 1 if method_descriptor.include? ')V' # If it is void
  end

  # --------------------------------------------------------------------------------------------------------------------
  def execute_static_method(frame_stack)
    actual_frame = frame_stack[fp]

    # Get method and class index
    method_index = actual_frame.method[:attributes][0][:code][actual_frame.pc+1, 2].join('').to_i(16)
    method_constant = actual_frame.java_class.constant_pool[method_index-1]
    name_and_type_index = method_constant[:name_and_type_index]

    # Get class_name
    class_index = method_constant[:class_index]
    class_constant = actual_frame.java_class.constant_pool[class_index-1]
    class_name = actual_frame.java_class.get_from_constant_pool(class_constant[:name_index])

    # Get method
    method_constant = actual_frame.java_class.constant_pool[name_and_type_index-1]
    method_name = actual_frame.java_class.get_from_constant_pool(method_constant[:name_index])
    method_descriptor = actual_frame.java_class.get_from_constant_pool(method_constant[:descriptor_index])

    MRjvm.debug('Invoking static method: ' << method_name << ', descriptor: ' << method_descriptor)

    # Get class
    java_class = class_heap.get_class(class_name)
    method_index = java_class.get_method_index(method_name, method_descriptor, true)
    method = java_class.methods[method_index]

    # Get parameters count, -1 because of this is static method.
    parameters_count = get_method_parameters_count(method_descriptor) - 1

    # Prepare frame for invoked method
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SUPER) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class.get_super_class, method, parameters_count)
    elsif (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_native_method(java_class, method)
    else
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class, method, parameters_count)
    end

    # Copy arguments to locals
    # frame_stack[fp+1].sp = actual_frame.sp
    for i in 0..parameters_count do
      frame_stack[fp+1].locals[i] = actual_frame.stack[actual_frame.sp-parameters_count+i]
    end

    MRjvm::MRjvm.mutex.synchronize do
      @fp += 1
    end

    # Execute next method
    return_value = execute(frame_stack)

    MRjvm::MRjvm.mutex.synchronize do
      @fp -= 1
    end

    # Remove parameters from stack and store return value.
    actual_frame.sp -= parameters_count
    actual_frame.stack[actual_frame.sp] = return_value # At top should be return value
    actual_frame.sp -= 1 if method_descriptor.include? ')V' # If it is void
  end

  # --------------------------------------------------------------------------------------------------------------------
  def execute_virtual_method(frame_stack)
    actual_frame = frame_stack[fp]

    # Get method and class indexes
    method_index = actual_frame.method[:attributes][0][:code][actual_frame.pc+1, 2].join.to_i(16)
    method_constant = actual_frame.java_class.constant_pool[method_index-1]
    name_and_type_index = method_constant[:name_and_type_index]

    # Get class info
    class_index = method_constant[:class_index]
    class_constant = actual_frame.java_class.constant_pool[class_index-1]
    class_name = actual_frame.java_class.get_from_constant_pool(class_constant[:name_index])

    # Get method info
    method_constant = actual_frame.java_class.constant_pool[name_and_type_index-1]
    method_name = actual_frame.java_class.get_from_constant_pool(method_constant[:name_index])
    method_descriptor = actual_frame.java_class.get_from_constant_pool(method_constant[:descriptor_index])

    MRjvm.debug('Invoking virtual method: ' << method_name << ', descriptor: ' << method_descriptor)

    # Get parameters count to get object ref
    parameters_count = get_method_parameters_count(method_descriptor)

    # Get object ref
    object_pointer = actual_frame.stack[actual_frame.sp - parameters_count]
    object = object_heap.get_object(object_pointer)

    # Get class and method
    java_class = get_virtual_method_class(object.type, method_name, method_descriptor)
    method = java_class.get_method(method_name, method_descriptor)

    # ------------------------------------------------------------------------------------------------------------------
    # TODO
    # Method must not be initialization method.
    # If method is protected and is member of super class of current class, then objectref must be current class or
    # subclass of current class.
    # ------------------------------------------------------------------------------------------------------------------


    # Prepare frame for invoked method
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SUPER) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class.get_super_class, method, parameters_count)
    elsif (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_native_method(java_class, method)
    else
      frame_stack[fp+1] = Heap::Frame.initialize_with_class_method(java_class, method, parameters_count)
    end

    # Copy parameters to locals
    # frame_stack[fp+1].sp = actual_frame.sp
    for i in 0..parameters_count do
      frame_stack[fp+1].locals[i] = actual_frame.stack[actual_frame.sp-parameters_count+i]
    end

    MRjvm::MRjvm.mutex.synchronize do
      @fp += 1
    end

    # Execute next method
    return_value = execute(frame_stack)

    MRjvm::MRjvm.mutex.synchronize do
      @fp -= 1
    end

    # Remove parameters from stack and store return value.
    actual_frame.sp -= parameters_count
    actual_frame.stack[actual_frame.sp] = return_value # At top should be return value
    actual_frame.sp -= 1 if method_descriptor.include? ')V' # If it is void
  end

  # --------------------------------------------------------------------------------------------------------------------
  # Get class which has implementation of virtual method.
  def get_virtual_method_class(java_class, method_name, method_descriptor)
    if java_class.is_overriding_method(method_name, method_descriptor) || java_class.get_method(method_name, method_descriptor) != -1
      java_class
    else
      if java_class.super_class_str == 'java/lang/Object'
        raise AbstractMethodError
      else
        get_virtual_method_class(java_class.get_super_class, method_name, method_descriptor)
      end
    end
  end

  # --------------------------------------------------------------------------------------------------------------------
  # Get class which has implementation of method.
  def get_special_method_class(super_class, method_name, method_descriptor)
    super_class_method_index = super_class.get_method_index(method_name, method_descriptor, false)
    if super_class_method_index == -1
      raise AbstractMethodError if super_class.super_class_str == 'java/lang/Object'
      get_special_method_class(super_class.get_super_class, method_name, method_descriptor)
    else
      super_class
    end
  end

  # --------------------------------------------------------------------------------------------------------------------
  # Count parameters of method.
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