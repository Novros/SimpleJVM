module ExecutionCoreNative
  def execute_native_method(frame_stack)
    MRjvm.debug('Invoking native method.')

    frame = frame_stack[@fp]
    java_class = frame.java_class
    class_name = java_class.this_class_str
    method_name = java_class.get_from_constant_pool(frame.method[:name_index])
    method_descriptor = java_class.get_from_constant_pool(frame.method[:descriptor_index])

    MRjvm.debug('Invoking native method: ' << method_name << ', descriptor: ' << method_descriptor)

    signature = class_name + '@' + method_name + method_descriptor
    native_method = get_fake_native_method(signature)

    runtime_environment = Native::NativeRunner.new
    runtime_environment.frame = frame
    runtime_environment.class_heap = class_heap
    runtime_environment.object_heap = object_heap
    if native_method.include? 'true_native'
      runtime_environment.run(signature, true)
    else
      runtime_environment.run(native_method, false)
    end
  end

  # TODO: Only for testing
  def get_fake_native_method(signature)
    if signature.include? 'java/lang/String@valueOf(F)Ljava/lang/String;'
      'string_value_of_f'
    elsif signature.include? 'java/lang/String@valueOf(J)Ljava/lang/String;'
      'string_value_of_j'
    elsif signature.include? 'java/lang/StringBuilder@append(Ljava/lang/String;)Ljava/lang/StringBuilder;'
      'string_builder_append_s'
    elsif signature.include? 'java/lang/StringBuilder@append(I)Ljava/lang/StringBuilder;'
      'string_builder_append_number'
    elsif signature.include? 'java/lang/StringBuilder@append(C)Ljava/lang/StringBuilder;'
      'string_builder_append_c'
    elsif signature.include? 'java/lang/StringBuilder@append(Z)Ljava/lang/StringBuilder;'
      'string_builder_append_z'
    elsif signature.include? 'java/lang/StringBuilder@append(Ljava/lang/Object;)Ljava/lang/StringBuilder;'
      'string_builder_append_o'
    elsif signature.include? 'java/lang/StringBuilder@append(F)Ljava/lang/StringBuilder;'
      'string_builder_append_number'
    elsif signature.include? 'java/lang/StringBuilder@append(J)Ljava/lang/StringBuilder;'
      'string_builder_append_number'
    elsif signature.include? 'java/lang/StringBuilder@append(D)Ljava/lang/StringBuilder;'
      'string_builder_append_number'
    elsif signature.include? 'java/lang/StringBuilder@toString()Ljava/lang/String;'
      'string_builder_to_string_string'
    elsif signature.include? 'java/io/PrintStream@println(Ljava/lang/String;)V'
      'native_print'
    elsif signature.include? 'java/lang/System@loadLibrary(Ljava/lang/String;)V'
      'load_native_library'
    elsif signature.include? 'InputFile@readLine()Ljava/lang/String;'
      'read_line'
    elsif signature.include? 'InputFile@readFile()Ljava/lang/String;'
      'read_file'
    elsif signature.include? 'InputFile@open(Ljava/lang/String;)V'
      'open_read'
    elsif signature.include? 'InputFile@close()V'
      'close_read'
    elsif signature.include? 'OutputFile@open(Ljava/lang/String;)V'
      'open_write'
    elsif signature.include? 'OutputFile@close()V'
      'close_write'
    elsif signature.include? 'OutputFile@writeLine(Ljava/lang/String;)V'
      'write_line'
    elsif signature.include? 'OutputFile@write(Ljava/lang/String;)V'
      'write'
    else
      puts signature
      'true_native'
    end
  end
end