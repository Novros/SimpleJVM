require_relative 'class_file/reader/modules/access_flags_reader'
require_relative 'heap/frame'
require_relative 'op_codes'
require_relative 'native/runtime_environment'

class ExecutionCore
  attr_accessor :class_heap, :object_heap, :fp

  def execute(frame_stack)
    frame = frame_stack[fp]

    if (frame.method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SYNTHETIC) != 0
      execute_native_method(frame_stack)
      return 0
    end

    # TODO This must return bytecode of method.
    byte_code = frame.method[:attributes][0][:code]
    java_class = frame.frame_class
    method_string = java_class.get_string_from_constant_pool(frame.method[:name_index])

    # TODO Some debug things
    while true

      puts '[DEBUG] ----------------------------------------------------------------'
      puts '[DEBUG] ' << fp.to_s << ':' << frame.pc.to_s << ' Next bytecode ' << byte_code[frame.pc]
      puts class_heap.to_s
      puts object_heap.to_s

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

        #-------------------------------------------------------------------------
        when OpCodes::BYTE_BIPUSH
          frame.sp += 1
          frame.stack[frame.sp] = byte_code[frame.pc+1]
          frame.pc += 2
        when OpCodes::BYTE_SIPUSH
          frame.sp += 1
          # TODO Here must be load 2 bytes.
          frame.stack[frame.sp] = (byte_code[frame.pc+1] + byte_code[frame.pc+2]).to_i(16)
          frame.sp += 3
        when OpCodes::BYTE_LCONST_0, OpCodes::BYTE_LCONST_1
          frame.sp += 1
          frame.stack[frame.sp] = 0
          frame.sp += 1
          frame.stack[frame.sp] = byte_code[frame.pc] - OpCodes::BYTE_LCONST_0
          frame.pc += 1
        when OpCodes::BYTE_LDC
          frame.sp += 1
          frame.stack[frame.sp] = load_constant(frame.frame_class, byte_code[frame.pc+1].to_i(16))
          frame.pc += 2
        # when OpCodes::BYTE_LDC2_W
        when OpCodes::BYTE_ILOAD, OpCodes::BYTE_ALOAD
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code[frame.pc+1].to_i(16)]
          frame.pc += 2
        # when OpCodes::BYTE_LLOAD
        when OpCodes::BYTE_ILOAD_0, OpCodes::BYTE_ILOAD_1, OpCodes::BYTE_ILOAD_2, OpCodes::BYTE_ILOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_ILOAD_0]
          frame.pc += 1
        when OpCodes::BYTE_LLOAD_0, OpCodes::BYTE_LLOAD_1, OpCodes::BYTE_LLOAD_2, OpCodes::BYTE_LLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_LLOAD_0]
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_LLOAD_0+1]
          frame.pc += 1
        when OpCodes::BYTE_FLOAD_0, OpCodes::BYTE_FLOAD_1, OpCodes::BYTE_FLOAD_2, OpCodes::BYTE_FLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_FLOAD_0]
        when OpCodes::BYTE_ALOAD_0, OpCodes::BYTE_ALOAD_1, OpCodes::BYTE_ALOAD_2, OpCodes::BYTE_ALOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.stack[byte_code_int - OpCodes::BYTE_ALOAD_0]
          frame.pc += 1
        # when OpCodes::BYTE_IALOAD
        # when OpCodes::BYTE_AALOAD
        when OpCodes::BYTE_ISTORE, OpCodes::BYTE_ASTORE
          frame.sp -= 1
          frame.stack[byte_code[frame.pc+1].to_i(16)] = frame.stack[frame.sp]
          frame.pc += 2
        when OpCodes::BYTE_ISTORE_0, OpCodes::BYTE_ISTORE_1, OpCodes::BYTE_ISTORE_2, OpCodes::BYTE_ISTORE_3
          frame.stack[byte_code_int - OpCodes::BYTE_ISTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_LSTORE_0, OpCodes::BYTE_LSTORE_1, OpCodes::BYTE_LSTORE_2, OpCodes::BYTE_LSTORE_3
          frame.stack[byte_code_int - OpCodes::BYTE_LCONST_0 + 1] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.stack[byte_code_int - OpCodes::BYTE_LCONST_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_FSTORE_0, OpCodes::BYTE_FSTORE_1, OpCodes::BYTE_FSTORE_2, OpCodes::BYTE_FSTORE_3
          frame.stack[byte_code_int - OpCodes::BYTE_FSTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_ASTORE_0, OpCodes::BYTE_ASTORE_1, OpCodes::BYTE_ASTORE_2, OpCodes::BYTE_ASTORE_3
          frame.stack[byte_code_int - OpCodes::BYTE_ASTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IASTORE, OpCodes::BYTE_AASTORE
          raise StandardError, 'TODO'
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
        when OpCodes::BYTE_IINC
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
          puts '[DEBUG] Return from function.'

          frame.stack[0] = frame.stack[frame.sp]
          return OpCodes::BYTE_IRETURN
        when OpCodes::BYTE__RETURN
          puts '[DEBUG] Return from procedure.'

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
          puts '[DEBUG] Invoking virtual method.'
          execute_invoke(frame_stack, false)
          frame.pc += 3
        when OpCodes::BYTE_INVOKESPECIAL
          puts '[DEBUG] Invoking special method.'
          execute_invoke(frame_stack, false)
          frame.pc += 3
        when OpCodes::BYTE_INVOKESTATIC
          puts '[DEBUG] Invkoking static method'
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

  def load_constant(java_class, index)
    puts '[DEBUG] Loading constant from pool, class: ' << java_class.this_class_str << ', index: ' << index.to_s

    constant = java_class.constant_pool[index-1]

    case constant[:tag]
      when 8 # String
        value = java_class.get_string_from_constant_pool(constant[:string_index])
        puts '[DEBUG] Loaded:"' << value << '"'
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

    puts '[DEBUG] Put field into object: ' << object_id << ' on index: ' << index << ' with value: ' << value

    var_list[index+1] = value
  end

  def get_field(frame)
    index = frame.method[:attributes][0][:code][frame.pc+1].to_i(16)
    object_id = frame.stack[frame.sp]
    var_list = object_heap.get_object(object_id).variables

    puts '[DEBUG] Reading field from object: ' << object_id << ' on index: ' << index

    frame.stack[frame.sp] = var_list[index+1]
  end

  def execute_new(frame)
    frame.sp += 1
    byte_code = frame.method[:attributes][0][:code]
    index = byte_code[frame.pc+1].to_i(16)

    puts '[DEBUG] Executed new on class index: ' << index.to_s << ' in class ' << frame.frame_class.this_class_str

    frame.stack[frame.sp] = frame.frame_class.create_object(index, @object_heap)
  end

  def execute_invoke_static(frame)
    # code here
  end

  def execute_invoke_virtual(frame)
    # code here
  end

  def execute_invoke(frame_stack, static)
    method_index = frame_stack[fp].method[:attributes][0][:code][frame_stack[fp].pc+1].to_i(16)
    object_ref = frame_stack[fp].stack[frame_stack[fp].sp]
    constant = frame_stack[fp].frame_class.constant_pool[method_index]

    class_index = constant[:class_index]
    name_and_type_index = constant[:name_and_type_index]

    constant = frame_stack[fp].frame_class.constant_pool[class_index-1]
    class_name = frame_stack[fp].frame_class.get_string_from_constant_pool(constant[:name_index])
    java_class = class_heap.get_class(class_name)

    constant = frame_stack[fp].frame_class.constant_pool[name_and_type_index-1]
    method_name = frame_stack[fp].frame_class.get_string_from_constant_pool(constant[:name_index])
    method_descriptor = frame_stack[fp].frame_class.get_string_from_constant_pool(constant[:descriptor_index])

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
    if (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_SYNTHETIC) != 0
    else
      discard_stack += method[:attributes][0][:max_locals]
    end

    frame_stack[fp+1].stack = Heap::Frame.op_stack
    frame_stack[fp+1].sp = frame_stack[fp].sp + discard_stack - 1
    frame_stack[fp+1].pc = 0

    puts '[DEBUG] Invoking method ' << method_name << ' ' << method_descriptor

    @fp += 1
    execute(frame_stack)
    @fp -= 1

    if method_descriptor.include? '()V'
       discard_stack -= 1
    end
    frame_stack[fp].sp -= discard_stack
  end

  def get_method_parameters_stack_count(method_descriptor)
    count = 0
    puts '[DEBUG][TODO] ' << method_descriptor
    for i in 1..method_descriptor.size
      if method_descriptor[i] == 'L'
        while method_descriptor[i] != ';'
          i += 1
        end
      elsif method_descriptor[i] == ')'
        break
      elsif method_descriptor[i] == 'J' || method_descriptor[i] == 'D'
        count +=1
      end
      count += 1
    end
    count
  end

  def execute_native_method(frame_stack)
    puts '[DEBUG] Invoking native method.'

    frame = frame_stack[0]

    java_class = frame.frame_class
    class_name = java_class.this_class_str
    method_name = java_class.get_string_from_constant_pool(frame.method[:name_index])
    descriptor = java_class.get_string_from_constant_pool(frame.method[:descriptor_index])

    signature = class_name << '@' << method_name << descriptor
    native_method = get_native_method(signature)

    runtime_environment = Native::RuntimeEnvironment.new
    runtime_environment.frame_stack = frame_stack
    runtime_environment.class_heap = class_heap
    runtime_environment.object_heap = object_heap

    return_value = runtime_environment.run(native_method)
    frame.stack[0] = return_value if descriptor.include? '()V'
  end

  # TODO: Only for testing
  def get_native_method(signature)
    return 'native_print'
  end
end