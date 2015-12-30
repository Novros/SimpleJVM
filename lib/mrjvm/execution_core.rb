require_relative 'class_file/reader/modules/access_flags_reader'
require_relative 'heap/frame'
require_relative 'op_codes'
require_relative 'native/runtime_environment'

class ExecutionCore
  attr_accessor :class_heap, :object_heap, :fp

  def execute(frame_stack)
    frame = frame_stack[fp]


    if (frame.method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
      MRjvm::debug('----------------------------------------------------------------')
      MRjvm::debug('' << fp.to_s)
      MRjvm::debug('[STACK] sp: ' << frame.sp.to_s)
      MRjvm::debug(get_stack_string(frame))
      execute_native_method(frame_stack)
      return 0
    end

    byte_code = frame.method[:attributes][0][:code]

    while true
      MRjvm::debug('----------------------------------------------------------------')
      MRjvm::debug('' << fp.to_s << ':' << frame.pc.to_s << ' bytecode ' << byte_code[frame.pc])
      MRjvm::debug('[STACK] sp: ' << frame.sp.to_s)
      MRjvm::debug(get_stack_string(frame))
      MRjvm::debug(class_heap.to_s)
      MRjvm::debug(object_heap.to_s)

      byte_code_int = byte_code[frame.pc].to_i(16)

      case byte_code_int
        #-------------------------------------------------------------------------
        when OpCodes::BYTE_NOP
          frame.pc += 1

        #------------------------------- Push constant ----------------------------
        when OpCodes::BYTE_ACONST_NULL
          frame.sp += 1
          frame.stack[frame.sp] = nil
          frame.pc += 1
        when OpCodes::BYTE_ICONST_M1, OpCodes::BYTE_ICONST_0, OpCodes::BYTE_ICONST_1, OpCodes::BYTE_ICONST_2, OpCodes::BYTE_ICONST_3, OpCodes::BYTE_ICONST_4, OpCodes::BYTE_ICONST_5
          frame.sp += 1
          frame.stack[frame.sp] = byte_code_int - OpCodes::BYTE_ICONST_0
          frame.pc += 1
        # when OpCodes::BYTE_LCONST_0, OpCodes::BYTE_LCONST_1
        #   frame.sp += 1
        #   frame.stack[frame.sp] = 0
        #   frame.sp += 1
        #   frame.stack[frame.sp] = byte_code_int - OpCodes::BYTE_LCONST_0
        #   frame.pc += 1
        when OpCodes::BYTE_FCONST_0
          frame.sp += 1
          frame.stack[frame.sp] = 0.0
          frame.pc += 1
        when OpCodes::BYTE_FCONST_1
          frame.sp += 1
          frame.stack[frame.sp] = 1.0
          frame.pc += 1
        when OpCodes::BYTE_FCONST_2
          frame.sp += 1
          frame.stack[frame.sp] = 2.0
          frame.pc += 1
        # when OpCodes::BYTE_DCONST_0
        #   frame.sp += 1
        #   frame.stack[frame.sp] = 0.0
        #   frame.pc += 1
        # when OpCodes::BYTE_DCONST_1
        #   frame.sp += 1
        #   frame.stack[frame.sp] = 1.0
        #   frame.pc += 1
        #-------------------------------------------------------------------------
        when OpCodes::BYTE_BIPUSH
          frame.sp += 1
          frame.stack[frame.sp] = byte_code[frame.pc+1].to_i(16)
          frame.pc += 2
        when OpCodes::BYTE_SIPUSH
          frame.sp += 1
          frame.stack[frame.sp] = (byte_code[frame.pc+1,2].join('').to_i(16))
          frame.sp += 3
        when OpCodes::BYTE_LDC
          frame.sp += 1
          frame.stack[frame.sp] = load_constant(frame.frame_class, byte_code[frame.pc+1].to_i(16))
          frame.pc += 2
        # when OpCodes::BYTE_LDC_W
        # when OpCodes::BYTE_LDC2_W
        when OpCodes::BYTE_ILOAD, OpCodes::BYTE_FLOAD, OpCodes::BYTE_DLOAD, OpCodes::BYTE_ALOAD
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code[frame.pc+1].to_i(16)]
          frame.pc += 2
        # when OpCodes::BYTE_LLOAD
        when OpCodes::BYTE_ILOAD_0, OpCodes::BYTE_ILOAD_1, OpCodes::BYTE_ILOAD_2, OpCodes::BYTE_ILOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_ILOAD_0]
          frame.pc += 1
        # when OpCodes::BYTE_LLOAD_0, OpCodes::BYTE_LLOAD_1, OpCodes::BYTE_LLOAD_2, OpCodes::BYTE_LLOAD_3
        #   frame.sp += 1
        #   frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_LLOAD_0]
        #   frame.sp += 1
        #   frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_LLOAD_0+1]
        #   frame.pc += 1
        when OpCodes::BYTE_FLOAD_0, OpCodes::BYTE_FLOAD_1, OpCodes::BYTE_FLOAD_2, OpCodes::BYTE_FLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_FLOAD_0]
          frame.pc += 1
        when OpCodes::BYTE_ALOAD_0, OpCodes::BYTE_ALOAD_1, OpCodes::BYTE_ALOAD_2, OpCodes::BYTE_ALOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_ALOAD_0]
          frame.pc += 1
        # when OpCodes::BYTE_IALOAD
        # when OpCodes::BYTE_AALOAD
        when OpCodes::BYTE_ISTORE, OpCodes::BYTE_ASTORE
          frame.stack[byte_code[frame.pc+1].to_i(16)] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 2
        when OpCodes::BYTE_ISTORE_0, OpCodes::BYTE_ISTORE_1, OpCodes::BYTE_ISTORE_2, OpCodes::BYTE_ISTORE_3
          frame.stack[byte_code_int - OpCodes::BYTE_ISTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        # when OpCodes::BYTE_LSTORE_0, OpCodes::BYTE_LSTORE_1, OpCodes::BYTE_LSTORE_2, OpCodes::BYTE_LSTORE_3
        #   frame.stack[byte_code_int - OpCodes::BYTE_LCONST_0 + 1] = frame.stack[frame.sp]
        #   frame.sp -= 1
        #   frame.stack[byte_code_int - OpCodes::BYTE_LCONST_0] = frame.stack[frame.sp]
        #   frame.sp -= 1
        #   frame.pc += 1
        when OpCodes::BYTE_FSTORE_0, OpCodes::BYTE_FSTORE_1, OpCodes::BYTE_FSTORE_2, OpCodes::BYTE_FSTORE_3
          frame.stack[byte_code_int - OpCodes::BYTE_FSTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_ASTORE_0, OpCodes::BYTE_ASTORE_1, OpCodes::BYTE_ASTORE_2, OpCodes::BYTE_ASTORE_3
          frame.stack[byte_code_int - OpCodes::BYTE_ASTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IASTORE, OpCodes::BYTE_AASTORE
          raise StandardError, 'TODO, add array support'
          object_heap.get_object(frame.stack[frame.sp-2]) # TODO Implement
          frame.sp -= 3
          frame.pc += 1
        when OpCodes::BYTE_DUP
          frame.stack[frame.sp+1] = frame.stack[frame.sp]
          frame.sp += 1
          frame.pc += 1
        when OpCodes::BYTE_DUP_X1
          frame.stack[frame.sp+1] = frame.stack[frame.sp]
          frame.stack[frame.sp] = frame.stack[frame.sp-1]
          frame.stack[frame.sp-1] = frame.stack[frame.sp+1]
          frame.sp += 1
          frame.pc += 1
        when OpCodes::BYTE_DUP_X2
          raise StandardError, 'BYTE_DUP_X2'

        # -------------------------- Couting operations ----------------------------
        when OpCodes::BYTE_IADD
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] + frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        # when OpCodes::BYTE_LADD
        when OpCodes::BYTE_ISUB
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] - frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IMUL
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] * frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IDIV
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] / frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IINC
          # TODO Check
          frame.stack[frame.pc+1] += byte_code[frame.pc+2]
          frame.pc += 3

        # -------------------------- Control flow ----------------------------
        when OpCodes::BYTE_IFEQ
          (frame.stack[frame.sp] == 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFNE
          (frame.stack[frame.sp] == 0) ? frame.pc += 3 : frame.pc += byte_code[frame.pc+1].to_i(16)
          frame.sp -= 1
        when OpCodes::BYTE_IFLT
          (frame.stack[frame.sp] < 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFGE
          (frame.stack[frame.sp] >= 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFGT
          (frame.stack[frame.sp] > 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFLE
          (frame.stack[frame.sp] <= 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IF_ICMPEQ
          if frame.stack[frame.sp - 1] == frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPNE
          if frame.stack[frame.sp - 1] != frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPLT
          if frame.stack[frame.sp - 1] < frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPGE
          if frame.stack[frame.sp - 1] >= frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPGT
          if frame.stack[frame.sp - 1] > frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPLE
          if frame.stack[frame.sp - 1] <= frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2

        # ---------------------------------- Goto --------------------------------
        when OpCodes::BYTE__GOTO
          frame.pc += byte_code[frame.pc+1].to_i(16)

        # -------------------------- Return from methods -------------------------
        when OpCodes::BYTE_IRETURN
          MRjvm::debug('Return from function.')

          frame.stack[0] = frame.stack[frame.sp]
          return OpCodes::BYTE_IRETURN
        when OpCodes::BYTE__RETURN
          MRjvm::debug('Return from procedure.')

          return 0

        # -------------------------------- Fields --------------------------------
        when OpCodes::BYTE_GETFIELD
          get_field(frame)
          frame.pc += 3
        when OpCodes::BYTE_PUTFIELD
          put_field(frame_stack)
          frame.pc += 3

        # -------------------------- Invoking methods ----------------------------
        when OpCodes::BYTE_INVOKEVIRTUAL
          MRjvm::debug('Invoking virtual method.')
          execute_invoke(frame_stack, false)
          frame.pc += 3
        when OpCodes::BYTE_INVOKESPECIAL
          MRjvm::debug('Invoking special method.')
          execute_invoke(frame_stack, false)
          frame.pc += 3
        when OpCodes::BYTE_INVOKESTATIC
          MRjvm::debug('Invkoking static method')
          execute_invoke(frame_stack, true)
          frame.pc += 3

        # -------------------------------------------------------------------------
        when OpCodes::BYTE__NEW
          execute_new(frame)
          frame.pc += 3
        when OpCodes::BYTE_NEWARRAY
          execute_new_array(frame)
          frame.pc += 2
        when OpCodes::BYTE_ANEWARRAY
          execute_a_new_array(frame)
          frame.pc +=3

        # ------------------------------- Goto ------------------------------------
        when OpCodes::BYTE_ATHROW
          raise StandardError # Need exceptions

        # -------------------------------------------------------------------------
        # when OpCodes::BYTE_CHECKCAST
        # when OpCodes::BYTE_INSTANCEOF

        # -------------------------- Thread synchronization -----------------------
        when OpCodes::BYTE_MONITORENTER
          raise StandardError # Need object monitor
        when OpCodes::BYTE_MONITOREXIT
          raise StandardError # Need object monitor
        else
          raise StandardError, byte_code[frame.pc]
      end
    end
    0
  end

  def get_stack_string(frame)
    stack_string = "[STACK]\n["
    frame.stack.each_with_index do |i, index|
      stack_string << "(#{index} => #{i}), "
    end
    stack_string << "]"
  end

  def load_constant(java_class, index)
    MRjvm::debug('Loading constant from pool, class: ' << java_class.this_class_str << ', index: ' << index.to_s)

    constant = java_class.constant_pool[index-1]

    case constant[:tag]
      when 8 # String
        value = java_class.get_string_from_constant_pool(constant[:string_index])
        MRjvm::debug('Loaded:"' << value << '"')
      else
        raise StandardError, '[ERROR] load_constant ' << constant[:tag].to_s
    end
    value
  end

  def put_field(frame_stack)
    index = frame_stack[fp].method[:attributes][0][:code][frame_stack[fp].pc+1].to_i(16)
    object_id = frame_stack[fp].stack[frame_stack[fp].sp - 1]
    value = frame_stack[fp].stack[frame_stack[fp].sp]
    var_list = object_heap.get_object(object_id).variables

    MRjvm::debug('Put field into object: ' << object_id << ' on index: ' << index << ' with value: ' << value)

    var_list[index+1] = value
  end

  def get_field(frame)
    index = frame.method[:attributes][0][:code][frame.pc+1].to_i(16)
    object_id = frame.stack[frame.sp]
    var_list = object_heap.get_object(object_id).variables

    MRjvm::debug(' Reading field from object: ' << object_id << ' on index: ' << index)

    frame.stack[frame.sp] = var_list[index+1]
  end

  def execute_new(frame)
    frame.sp += 1
    byte_code = frame.method[:attributes][0][:code]
    index = byte_code[frame.pc+1].to_i(16)

    MRjvm::debug(' Executed new on class index: ' << index.to_s << ' in class ' << frame.frame_class.this_class_str)

    frame.stack[frame.sp] = frame.frame_class.create_object(index, object_heap)
  end

  def execute_invoke(frame_stack, static)
    method_index = frame_stack[fp].method[:attributes][0][:code][frame_stack[fp].pc+1, 2].join('').to_i(16)
    # object_ref = frame_stack[fp].stack[frame_stack[fp].sp] # TODO Add if using object variables
    constant = frame_stack[fp].frame_class.constant_pool[method_index-1]

    class_index = constant[:class_index]
    name_and_type_index = constant[:name_and_type_index]

    constant = frame_stack[fp].frame_class.constant_pool[class_index-1]
    class_name = frame_stack[fp].frame_class.get_string_from_constant_pool(constant[:name_index])
    java_class = class_heap.get_class(class_name)

    constant = frame_stack[fp].frame_class.constant_pool[name_and_type_index-1]
    method_name = frame_stack[fp].frame_class.get_string_from_constant_pool(constant[:name_index])
    method_descriptor = frame_stack[fp].frame_class.get_string_from_constant_pool(constant[:descriptor_index])

    MRjvm::debug(' Invoking method: ' << method_name << ', descriptor: ' << method_descriptor)

    method_index = java_class.get_method_index(method_name) # TODO Add descriptor
    method = java_class.methods[method_index]
    frame_stack[fp+1].method = method
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SUPER) != 0
      frame_stack[fp+1].frame_class = java_class.get_super_class
    else
      frame_stack[fp+1].frame_class = java_class
    end

    params = get_method_parameters_stack_count(method_descriptor) + 1
    params -= 1 if static
    discard_stack = params
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
    else
      discard_stack += method[:attributes][0][:max_locals]
    end

    frame_stack[fp+1].stack = Heap::Frame.op_stack
    frame_stack[fp+1].sp = frame_stack[fp].sp + discard_stack - 1
    frame_stack[fp+1].pc = 0

    @fp += 1
    execute(frame_stack)
    @fp -= 1

    # if method_descriptor.include? '()V'
    #    discard_stack -= 1
    # end
    # frame_stack[fp].sp -= discard_stack
  end

  def get_method_parameters_stack_count(method_descriptor)
    count = 0
    for i in 1..method_descriptor.size
      if method_descriptor[i] == 'L'
        count += 1
        while method_descriptor[i] != ';'
          i += 1
        end
      elsif method_descriptor[i] == ')'
        break
      elsif method_descriptor[i] == 'J' || method_descriptor[i] == 'D'
        count +=2
      end
    end
    MRjvm::debug('[METHOD][COUNT] ' << count.to_s)
    count
  end

  def execute_native_method(frame_stack)
    MRjvm::debug('[DEBUG] Invoking native method.')

    frame = frame_stack[@fp]

    java_class = frame.frame_class
    class_name = java_class.this_class_str
    method_name = java_class.get_string_from_constant_pool(frame.method[:name_index])
    descriptor = java_class.get_string_from_constant_pool(frame.method[:descriptor_index])

    MRjvm::debug(' Invoking native method: ' << method_name << ', descriptor: ' <<  descriptor)

    signature = class_name + '@' + method_name + descriptor
    native_method = get_native_method(signature)

    runtime_environment = Native::RuntimeEnvironment.new
    runtime_environment.frame_stack = frame_stack
    runtime_environment.class_heap = class_heap
    runtime_environment.object_heap = object_heap
    runtime_environment.fp = @fp

    return_value = runtime_environment.run(native_method)
    frame.stack[frame.sp] = return_value # if descriptor.include? '()V'
  end

  # TODO: Only for testing
  def get_native_method(signature)
    if signature.include? 'java/lang/String@valueOf(F)Ljava/lang/String;'
      'string_value_of_f'
    elsif signature.include? 'java/lang/String@valueOf(J)Ljava/lang/String;'
      'string_value_of_j'
    elsif signature.include? 'java/lang/StringBuilder@append(Ljava/lang/String;)Ljava/lang/StringBuilder;'
      'string_builder_append_i'
    elsif signature.include? 'java/lang/StringBuilder@append(I)Ljava/lang/StringBuilder;'
      'string_builder_append_i'
    elsif signature.include? 'java/lang/StringBuilder@append(C)Ljava/lang/StringBuilder;'
      'string_builder_append_c'
    elsif signature.include? 'java/lang/StringBuilder@append(Z)Ljava/lang/StringBuilder;'
      'string_builder_append_z'
    elsif signature.include? 'java/lang/StringBuilder@append(Ljava/lang/Object;)Ljava/lang/StringBuilder;'
      'string_builder_append_o'
    elsif signature.include? 'java/lang/StringBuilder@append(F)Ljava/lang/StringBuilder;'
      'string_builder_append_f'
    elsif signature.include? 'java/lang/StringBuilder@append(J)Ljava/lang/StringBuilder;'
      'string_builder_append_j'
    elsif signature.include? 'java/lang/StringBuilder@toString()Ljava/lang/String;'
      'string_builder_to_string_string'
    elsif signature.include? 'Test@Print(Ljava/lang/String;)V'
      'native_print'
    end
  end
end