module ExecutionCoreThrow
  # Implement athrow instruction
  def execute_throw(object_heap, frame_stack, fp)
    MRjvm.debug('Executing throw.')

    frame = frame_stack[fp]

    exception_pointer = frame.stack[frame.sp]
    exception_instance = object_heap.get_object(exception_pointer)

    fail MRjvmError, 'Thrown not throwable exception.' unless throwable?(exception_instance.type)

    while fp > -1
      frame = frame_stack[fp]
      while frame.sp > -1
        exception_table = get_exception_table(frame.method)
        exception_table.each do |item|
          catch_name = frame.java_class.get_from_constant_pool(item[:catch_type], true)
          catch?(exception_instance.type, catch_name) && (return)
        end
        frame.sp -= 1
      end

      fp -= 1
    end

    fail MRjvmError, 'Exception was thrown; Type: ' + exception_instance.type.this_class_str
  end

  # Look for code attribute in method
  def get_code_attribute_from_method(method)
    method[:attributes].each do |item|
      item.has_key?(:code) && (return item)
    end
    # attribute do not have exception table
    {}
  end

  # Look for exception table in method
  def get_exception_table(method)
    attribute = get_code_attribute_from_method(method)

    if attribute.has_key?(:exception_table)
      attribute[:exception_table]
    else
      {}
    end
  end

  # Check if exception was catched
  def catch?(exception_class, catch_type)
    until exception_class.nil?
      exception_name = exception_class.this_class_str

      exception_name == catch_type && (return true)
      exception_class = exception_class.get_super_class
    end
    false
  end

  # Check if thrown exception is instance or child of throwable class
  def throwable?(exception_class)
    until exception_class.nil?
      exception_name = exception_class.this_class_str
      puts exception_name
      exception_name == 'java/lang/Throwable' && (return true)
      exception_class = exception_class.get_super_class
    end
    false
  end
end