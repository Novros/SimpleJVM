require_relative 'class_file/reader/modules/access_flags_reader'
require_relative 'heap/frame'
require_relative 'op_codes'

class ExecutionCore
  attr_accessor :class_heap, :object_heap

  def execute(frame_stack)
    frame = frame_stack[0]

    if frame.method.access_flags & AccessFlagsReader::ACC_SYNTHETIC
      execute_native_method(frame)
      return 0
    end

    # TODO This must return bytecode of method.
    byte_code = frame.method[:attributes][:code]
    java_class = frame.frame_class
    method_string = java_class.get_string_from_constant_pool(frame.method[:name_index])

    # TODO Some debug things
    while true
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
          frame.stack[frame.sp].value = byte_code[frame.pc] - BYTE_ICONST_5
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
          frame.stack[frame.sp-1].value = frame.stack[frame.sp-1].value + frame.stack[frame.sp].value
          frame.sp -= 1
          frame.pc += 1
        # when BYTE_LADD
        when BYTE_ISUB
          frame.stack[frame.sp-1].value = frame.stack[frame.sp-1].value - frame.stack[frame.sp].value
          frame.sp -= 1
          frame.pc += 1
        when BYTE_IMUL
          frame.stack[frame.sp-1].value = frame.stack[frame.sp-1].value * frame.stack[frame.sp].value
          frame.sp -= 1
          frame.pc += 1
        when BYTE_IINC
          frame.stack[frame.pc+1].value += byte_code[frame.pc+2]
          frame.pc += 3

        # -------------------------- Control flow ----------------------------
        when BYTE_IFEQ
          (frame.stack[frame.sp].value == 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IFNE
          (frame.stack[frame.sp].value == 0) ? frame.pc += 3 : frame.pc += byte_code[frame.pc+1].to_i(16)
          frame.sp -= 1
        when BYTE_IFLT
          (frame.stack[frame.sp].value < 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IFGE
          (frame.stack[frame.sp].value >= 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IFGT
          (frame.stack[frame.sp].value > 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IFLE
          (frame.stack[frame.sp].value <= 0) ? frame.pc += byte_code[frame.pc+1].to_i(16) : frame.pc += 3
          frame.sp -= 1
        when BYTE_IF_ICMPEQ
          if frame.stack[frame.sp - 1].value == frame.stack[frame.sp].value
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPNE
          if frame.stack[frame.sp - 1].value != frame.stack[frame.sp].value
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPLT
          if frame.stack[frame.sp - 1].value < frame.stack[frame.sp].value
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPGE
          if frame.stack[frame.sp - 1].value >= frame.stack[frame.sp].value
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPGT
          if frame.stack[frame.sp - 1].value > frame.stack[frame.sp].value
            frame.pc += byte_code[frame.pc+1].to_i(16)
          else
            frame.pc += 3
          end
          frame.sp -= 2
        when BYTE_IF_ICMPLE
          if frame.stack[frame.sp - 1].value <= frame.stack[frame.sp].value
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
          frame.stack[0].value = frame.stack[frame.sp].value
        when BYTE__RETURN
          return 0

        # -------------------------------- Fields --------------------------------
        when BYTE_GETFIELD
          get_field(frame)
          frame.pc += 3
        when BYTE_PUTFIELD
          put_field(frame)
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
          excute_a_new_array(frame)
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

  def put_field(frame)
    # code here
  end

  def get_field(frame)
    # code here
  end

  def execute_new_array(frame)
    # code here
  end

  def excute_a_new_array(frame)
    # code here
  end

  def execute_new(frame)
    # code here
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

  def execute_native_method(frame)
    # code here
  end
end