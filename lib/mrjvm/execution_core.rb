require_relative 'class_file/reader/modules/access_flags_reader'
require_relative 'heap/frame'
require_relative 'op_codes'
require_relative 'native/runtime_environment'

class ExecutionCore
  attr_accessor :class_heap, :object_heap

  def execute(frame_stack)
    frame = frame_stack[0]

    if (frame.method[:access_flags].to_i & AccessFlagsReader::ACC_SYNTHETIC) != 0
      execute_native_method(frame_stack)
      return 0
    end

    # TODO This must return bytecode of method.
    byte_code = frame.method[:code]
    java_class = frame.frame_class
    method_string = java_class.get_string_from_constant_pool(frame.method[:name_index])

    # TODO Some debug things
    while true

      puts class_heap.to_s
      puts object_heap.to_s

      case byte_code[frame.pc]
        #-------------------------------------------------------------------------
        when BYTE_NOP
          frame.pc += 1

        #------------------------------- Push constant ----------------------------
        when BYTE_ACONST_NULL
          frame.sp += 1
          frame.stack[frame.sp].object.heap_ptr = 0
          frame.pc += 1
        # when BYTE_ICONST_M1
        # when BYTE_ICONST_0
        # when BYTE_ICONST_1
        # when BYTE_ICONST_2
        # when BYTE_ICONST_3
        # when BYTE_ICONST_4
        when BYTE_ICONST_5
          frame.sp += 1
          frame.stack[frame.sp] = byte_code[frame.pc] - BYTE_ICONST_5
          frame.pc += 1

        #-------------------------------------------------------------------------
        # when BYTE_BIPUSH
        # when BYTE_SIPUSH
        # when BYTE_LCONST_0
        # when BYTE_LCONST_1
        # when BYTE_LDC
        # when BYTE_LDC2_W
        # when BYTE_ILOAD
        # when BYTE_LLOAD
        # when BYTE_ALOAD
        # when BYTE_ILOAD_0
        # when BYTE_ILOAD_1
        # when BYTE_ILOAD_2
        # when BYTE_ILOAD_3
        # when BYTE_LLOAD_0
        # when BYTE_LLOAD_1
        # when BYTE_LLOAD_2
        # when BYTE_LLOAD_3
        # when BYTE_FLOAD_0
        # when BYTE_FLOAD_1
        # when BYTE_FLOAD_2
        # when BYTE_FLOAD_3
        # when BYTE_ALOAD_0
        # when BYTE_ALOAD_1
        # when BYTE_ALOAD_2
        # when BYTE_ALOAD_3
        # when BYTE_IALOAD
        # when BYTE_AALOAD
        # when BYTE_ISTORE
        # when BYTE_ASTORE
        # when BYTE_ISTORE_0
        # when BYTE_ISTORE_1
        # when BYTE_ISTORE_2
        # when BYTE_ISTORE_3
        # when BYTE_LSTORE_0
        # when BYTE_LSTORE_1
        # when BYTE_LSTORE_2
        # when BYTE_LSTORE_3
        # when BYTE_FSTORE_0
        # when BYTE_FSTORE_1
        # when BYTE_FSTORE_2
        # when BYTE_FSTORE_3
        # when BYTE_ASTORE_0
        # when BYTE_ASTORE_1
        # when BYTE_ASTORE_2
        # when BYTE_ASTORE_3
        # when BYTE_IASTORE
        # when BYTE_AASTORE
        # when BYTE_DUP
        # when BYTE_DUP_X1
        # when BYTE_DUP_X2

        # -------------------------- Couting operations ----------------------------
        when BYTE_IADD
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] + frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        # when BYTE_LADD
        when BYTE_ISUB
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] - frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when BYTE_IMUL
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] * frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when BYTE_IINC
          frame.stack[frame.pc+1] += byte_code[frame.pc+2]
          frame.pc += 3

        # -------------------------- Control flow ----------------------------
        when BYTE_IFEQ
          (frame.stack[frame.sp] == 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IFNE
          (frame.stack[frame.sp] == 0) ? frame.pc += 3 : frame.pc += byte_code[frame.pc+1].to_i(16)
          frame.sp -= 1
        when BYTE_IFLT
          (frame.stack[frame.sp] < 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IFGE
          (frame.stack[frame.sp] >= 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IFGT
          (frame.stack[frame.sp] > 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IFLE
          (frame.stack[frame.sp] <= 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IF_ICMPEQ
          if frame.stack[frame.sp - 1] == frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPNE
          if frame.stack[frame.sp - 1] != frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPLT
          if frame.stack[frame.sp - 1] < frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPGE
          if frame.stack[frame.sp - 1] >= frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPGT
          if frame.stack[frame.sp - 1] > frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPLE
          if frame.stack[frame.sp - 1] <= frame.stack[frame.sp]
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2

        # ---------------------------------- Goto --------------------------------
        when BYTE__GOTO
          frame.pc += byte_code[frame.pc+1].to_i(16)

        # -------------------------- Return from methods -------------------------
        when BYTE_IRETURN
          frame.stack[0] = frame.stack[frame.sp]
        when BYTE__RETURN
          return 0

        # -------------------------------- Fields --------------------------------
        when BYTE_GETFIELD
          get_field(frame)
          frame.pc += 3
        when BYTE_PUTFIELD
          put_field(frame_stack)
          frame.pc += 3

        # -------------------------- Invoking methods ----------------------------
        when BYTE_INVOKEVIRTUAL
          execute_invoke_special(frame)
          frame.pc += 3
        when BYTE_INVOKESPECIAL
          execute_invoke_virtual(frame)
          frame.pc += 3
        when BYTE_INVOKESTATIC
          execute_invoke_static(frame)
          frame.pc += 3

        # -------------------------------------------------------------------------
        when BYTE__NEW
          execute_new(frame)
          frame.pc += 3
        when BYTE_NEWARRAY
          execute_new_array(frame)
          frame.pc += 2
        when BYTE_ANEWARRAY
          execute_a_new_array(frame)
          frame.pc +=3

        # ------------------------------- Goto ------------------------------------
        when BYTE_ATHROW
          raise StandardError # Need exceptions

        # -------------------------------------------------------------------------
        # when BYTE_CHECKCAST
        # when BYTE_INSTANCEOF

        # -------------------------- Thread synchronization -----------------------
        when BYTE_MONITORENTER
          raise StandardError # Need object monitor
        when BYTE_MONITOREXIT
          raise StandardError # Need object monitor
        else
          raise StandardError
      end
    end
    0
  end

  def put_field(frame_stack)
    index = frame_stack[0].method[:code][frame_stack[0].pc+1].to_i(16)
    object_id = frame_stack[0].stack[frame_stack[0].sp - 1]
    value = frame_stack[0].stack[frame_stack[0].sp]
    var_list = object_heap.get_object(object_id).variables

    puts '[DEBUG] Put field into object: ' << object_id << ' on index: ' << index << ' with value: ' << value

    var_list[index+1] = value
  end

  def get_field(frame)
    index = frame.method[:code][frame.pc+1].to_i(16)
    object_id = frame.stack[frame.sp]
    var_list = object_heap.get_object(object_id).variables

    puts '[DEBUG] Reading field from object: ' << object_id << ' on index: ' << index

    frame.stack[frame.sp] = var_list[index+1]
  end

  def execute_new_array(frame)
    # code here
  end

  def execute_a_new_array(frame)
    # code here
  end

  def execute_new(frame)
    frame.sp += 1
    byte_code = frame.method[:code]
    index = byte_code[frame.pc+1].to_i(16)

    puts '[DEBUG] Executed new on class index: ' << index << ' in class ' << frame.frame_class

    frame.stack[frame.sp] = frame.frame_class.create_object(index, @object_heap)
  end

  def execute_invoke(frame_stack)
    # method_index = frame_stack[0].method[:code][frame_stack[0].pc+1]
    # object_ref = frame_stack[0].stack[frame_stack[0].sp]
    # method = frame_stack[0].frame_class.constant_pool[method_index]
    # class_index =
  end

  def execute_invoke_static(frame)
    # code here
  end

  def execute_invoke_virtual(frame)
    # code here
  end

  def execute_invoke_special(frame)
    # code here
  end

  def execute_native_method(frame_stack)
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