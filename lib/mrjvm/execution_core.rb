require_relative 'class_file/reader/modules/access_flags_reader'
require_relative 'heap/frame'
require_relative 'heap/class_heap'
require_relative 'heap/object_heap'
require_relative 'op_codes'
require_relative 'native/native_runner'

class ExecutionCore
  attr_accessor :class_heap, :object_heap, :fp

  def initialize
    @stack_var_zero = Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
    @gc = GarbageCollector.new
    # Start garbage collector
  end

  def execute(frame_stack)
    frame = frame_stack[fp]

    if (frame.method[:access_flags].to_i(16) & AccessFlagsReader::ACC_NATIVE) != 0
      MRjvm.debug('----------------------------------------------------------------')
      MRjvm.debug('' << fp.to_s)
      MRjvm.debug('[STACK] sp: ' << frame.sp.to_s)
      MRjvm.debug(get_locals_string(frame))
      MRjvm.debug(get_stack_string(frame))
      return execute_native_method(frame_stack)
    end

    byte_code = get_method_byte_code(frame)
    while true
      sleep 0.02
      MRjvm.debug('----------------------------------------------------------------')
      MRjvm.debug('' << fp.to_s << ':' << frame.pc.to_s << ' bytecode ' << byte_code[frame.pc])
      MRjvm.debug('[STACK] sp: ' << frame.sp.to_s)
      MRjvm.debug(get_locals_string(frame))
      MRjvm.debug(get_stack_string(frame))
      MRjvm.debug(class_heap.to_s)
      MRjvm.debug(object_heap.to_s)

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
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_INT, byte_code_int - OpCodes::BYTE_ICONST_0)
          frame.pc += 1
        when OpCodes::BYTE_LCONST_0, OpCodes::BYTE_LCONST_1
          frame.sp += 1
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_LONG, byte_code_int - OpCodes::BYTE_LCONST_0)
          frame.pc += 1
        when OpCodes::BYTE_FCONST_0
          frame.sp += 1
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_FLOAT, 0.0)
          frame.pc += 1
        when OpCodes::BYTE_FCONST_1
          frame.sp += 1
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_FLOAT, 1.0)
          frame.pc += 1
        when OpCodes::BYTE_FCONST_2
          frame.sp += 1
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_FLOAT, 2.0)
          frame.pc += 1
        when OpCodes::BYTE_DCONST_0
          frame.sp += 1
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_DOUBLE, 0.0)
          frame.pc += 1
        when OpCodes::BYTE_DCONST_1
          frame.sp += 1
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_DOUBLE, 1.0)
          frame.pc += 1
        #-------------------------------------------------------------------------
        when OpCodes::BYTE_BIPUSH
          frame.sp += 1
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_INT, byte_code[frame.pc+1].to_i(16))
          frame.pc += 2
        when OpCodes::BYTE_SIPUSH
          frame.sp += 1
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_SHORT, byte_code[frame.pc+1, 2].join('').to_i(16))
          frame.pc += 3
        when OpCodes::BYTE_LDC
          frame.sp += 1
          frame.stack[frame.sp] = load_constant(frame.java_class, byte_code[frame.pc+1].to_i(16))
          frame.pc += 2
        when OpCodes::BYTE_LDC_W
          frame.sp += 1
          frame.stack[frame.sp] = load_constant(frame.java_class, byte_code[frame.pc+1, 2].join('').to_i(16))
          frame.pc += 3
        when OpCodes::BYTE_LDC2_W
          frame.sp += 1
          frame.stack[frame.sp] = load_constant(frame.java_class, byte_code[frame.pc+1, 2].join('').to_i(16))
          frame.pc += 3
        when OpCodes::BYTE_ILOAD, OpCodes::BYTE_LLOAD, OpCodes::BYTE_FLOAD, OpCodes::BYTE_DLOAD, OpCodes::BYTE_ALOAD
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code[frame.pc+1].to_i(16)]
          frame.pc += 2
        when OpCodes::BYTE_ILOAD_0, OpCodes::BYTE_ILOAD_1, OpCodes::BYTE_ILOAD_2, OpCodes::BYTE_ILOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_ILOAD_0]
          frame.pc += 1
        when OpCodes::BYTE_LLOAD_0, OpCodes::BYTE_LLOAD_1, OpCodes::BYTE_LLOAD_2, OpCodes::BYTE_LLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_LLOAD_0]
          frame.pc += 1
        when OpCodes::BYTE_FLOAD_0, OpCodes::BYTE_FLOAD_1, OpCodes::BYTE_FLOAD_2, OpCodes::BYTE_FLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_FLOAD_0]
          frame.pc += 1
        when OpCodes::BYTE_DLOAD_0, OpCodes::BYTE_DLOAD_1, OpCodes::BYTE_DLOAD_2, OpCodes::BYTE_DLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_DLOAD_0]
          frame.pc += 1
        when OpCodes::BYTE_ALOAD_0, OpCodes::BYTE_ALOAD_1, OpCodes::BYTE_ALOAD_2, OpCodes::BYTE_ALOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_ALOAD_0]
          frame.pc += 1
        when OpCodes::BYTE_IALOAD, OpCodes::BYTE_LALOAD, OpCodes::BYTE_FALOAD, OpCodes::BYTE_DALOAD, OpCodes::BYTE_AALOAD, OpCodes::BYTE_BALOAD, OpCodes::BYTE_CALOAD, OpCodes::BYTE_SALOAD
          frame.stack[frame.sp-1] = object_heap.get_value_from_array(frame.stack[frame.sp-1], frame.stack[frame.sp].value)
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_ISTORE, OpCodes::BYTE_LSTORE, OpCodes::BYTE_FSTORE, OpCodes::BYTE_DSTORE, OpCodes::BYTE_ASTORE
          frame.locals[byte_code[frame.pc+1].to_i(16)] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 2
        when OpCodes::BYTE_ISTORE_0, OpCodes::BYTE_ISTORE_1, OpCodes::BYTE_ISTORE_2, OpCodes::BYTE_ISTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_ISTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_LSTORE_0, OpCodes::BYTE_LSTORE_1, OpCodes::BYTE_LSTORE_2, OpCodes::BYTE_LSTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_LSTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_FSTORE_0, OpCodes::BYTE_FSTORE_1, OpCodes::BYTE_FSTORE_2, OpCodes::BYTE_FSTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_FSTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_DSTORE_0, OpCodes::BYTE_DSTORE_1, OpCodes::BYTE_DSTORE_2, OpCodes::BYTE_DSTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_DSTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_ASTORE_0, OpCodes::BYTE_ASTORE_1, OpCodes::BYTE_ASTORE_2, OpCodes::BYTE_ASTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_ASTORE_0] = frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IASTORE, OpCodes::BYTE_LASTORE, OpCodes::BYTE_FASTORE, OpCodes::BYTE_DASTORE, OpCodes::BYTE_AASTORE, OpCodes::BYTE_BASTORE, OpCodes::BYTE_CASTORE, OpCodes::BYTE_SASTORE
          frame.sp -= 3
          object_heap.get_object(frame.stack[frame.sp+1]).variables[frame.stack[frame.sp+2].value] = frame.stack[frame.sp+3]
          frame.pc += 1
        when OpCodes::BYTE_POP
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_POP2
          (frame.stack[frame.sp].type == Heap::VARIABLE_DOUBLE || frame.stack[frame.sp].type == Heap::VARIABLE_LONG) ?
              frame.sp -=1 :
              frame.sp -= 2
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
        # when OpCodes::BYTE_DUP_X2
        # when OpCodes::BYTE_DUP2
        # when OpCodes::BYTE_DUP2_X1
        # when OpCodes::BYTE_DUP2_X2
        when OpCodes::BYTE_SWAP
          temp = frame.stack[frame.sp]
          frame.stack[frame.sp] = frame.stack[frame.sp-1]
          frame.stack[frame.sp-1] = temp
          frame.pc += 1
        # -------------------------- Counting operations ----------------------------
        when OpCodes::BYTE_IADD, OpCodes::BYTE_LADD, OpCodes::BYTE_FADD, OpCodes::BYTE_DADD
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] + frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_ISUB, OpCodes::BYTE_LSUB, OpCodes::BYTE_FSUB, OpCodes::BYTE_DSUB
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] - frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IMUL, OpCodes::BYTE_LMUL, OpCodes::BYTE_FMUL, OpCodes::BYTE_DMUL
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] * frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IDIV, OpCodes::BYTE_LDIV, OpCodes::BYTE_FDIV, OpCodes::BYTE_DDIV
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] / frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IREM, OpCodes::BYTE_LREM, OpCodes::BYTE_FREM, OpCodes::BYTE_DREM
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] % frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        # -------------------------- Bitwise operations ----------------------------
        when OpCodes::BYTE_INEG, OpCodes::BYTE_LNEG, OpCodes::BYTE_FNEG, OpCodes::BYTE_DNEG
          frame.stack[frame.sp] = !frame.stack[frame.sp]
          frame.pc += 1
        when OpCodes::BYTE_ISHL, OpCodes::BYTE_LSHL
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] << frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_ISHR, OpCodes::BYTE_LSHR, OpCodes::BYTE_LUSHR
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] >> frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        # when OpCodes::BYTE_IUSHR
        when OpCodes::BYTE_IAND, OpCodes::BYTE_LAND
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] & frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IOR, OpCodes::BYTE_LOR
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] | frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IXOR, OpCodes::BYTE_LXOR
          frame.stack[frame.sp-1] = frame.stack[frame.sp-1] ^ frame.stack[frame.sp]
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IINC
          bytes = byte_code[frame.pc+2]
          frame.locals[byte_code[frame.pc+1].to_i(16)].value += [bytes.scan(/[0-9a-f]{2}/i).reverse.join].pack('H*').unpack('c')[0]
          frame.pc += 3
        # -------------------------- Conversion operations ----------------------------
        when OpCodes::BYTE_I2L
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_LONG, frame.stack[frame.sp].value)
          frame.pc += 1
        when OpCodes::BYTE_I2F
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_FLOAT, frame.stack[frame.sp].value.to_f)
          frame.pc += 1
        when OpCodes::BYTE_I2D
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_DOUBLE, frame.stack[frame.sp].value.to_f)
          frame.pc += 1
        when OpCodes::BYTE_L2I
          long_value = frame.stack[frame.sp].value
          int_value = ''
          (0...32).each do |i|
            int_value << long_value[31-i].to_s
          end
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_INT, int_value.to_i(2))
          frame.pc += 1
        when OpCodes::BYTE_L2F
          # TODO float and double has not same size
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_FLOAT, frame.stack[frame.sp].value.to_f)
          frame.pc += 1
        when OpCodes::BYTE_L2D
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_DOUBLE, frame.stack[frame.sp].value.to_f)
          frame.pc += 1
        when OpCodes::BYTE_F2I
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_INT, frame.stack[frame.sp].value.to_i)
          frame.pc += 1
        when OpCodes::BYTE_F2L
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_LONG, frame.stack[frame.sp].value.to_i)
          frame.pc += 1
        when OpCodes::BYTE_F2D
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_DOUBLE, frame.stack[frame.sp].value)
          frame.pc += 1
        when OpCodes::BYTE_D2I
          # TODO Double and int has not same size
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_INT, frame.stack[frame.sp].value.to_i)
          frame.pc += 1
        when OpCodes::BYTE_D2L
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_LONG, frame.stack[frame.sp].value.to_i)
          frame.pc += 1
        when OpCodes::BYTE_D2F
          # TODO float and double has not same size
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_FLOAT, frame.stack[frame.sp].value)
          frame.pc += 1
        when OpCodes::BYTE_I2B
          value = frame.stack[frame.sp].value
          int_value = ''
          (0...8).each do |i|
            int_value << value[7-i].to_s
          end
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_BYTE, int_value.to_i(2))
          frame.pc += 1
        when OpCodes::BYTE_I2C
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_CHAR, frame.stack[frame.sp].value.to_s)
          frame.pc += 1
        when OpCodes::BYTE_I2S
          int_value = frame.stack[frame.sp].value
          short_value = ''
          (0...16).each do |i|
            short_value << int_value[15-i].to_s
          end
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_SHORT, short_value.to_i(2))
          frame.pc += 1
        # -------------------------- Control flow ----------------------------
        when OpCodes::BYTE_LCMP, OpCodes::BYTE_FCMPL, OpCodes::BYTE_FCMPG, OpCodes::BYTE_DCMPL, OpCodes::BYTE_DCMPG
          frame.stack[frame.sp-1] = Heap::StackVariable.new(Heap::VARIABLE_INT, frame.stack[frame.sp] <=> frame.stack[frame.sp-1])
          frame.sp -=1
          frame.pc +=1
        when OpCodes::BYTE_IFEQ
          (frame.stack[frame.sp] == @stack_var_zero) ? frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFNE
          (frame.stack[frame.sp] != @stack_var_zero) ? frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFLT
          (frame.stack[frame.sp] < @stack_var_zero) ? frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFGE
          (frame.stack[frame.sp] >= @stack_var_zero) ? frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFGT
          (frame.stack[frame.sp] > @stack_var_zero) ? frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFLE
          (frame.stack[frame.sp] <= @stack_var_zero) ? frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IF_ICMPEQ, OpCodes::BYTE_IF_ACMPEQ
          (frame.stack[frame.sp - 1] == frame.stack[frame.sp]) ?
              frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) :
              frame.pc += 3
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPNE, OpCodes::BYTE_IF_ACMPNE
          (frame.stack[frame.sp - 1] != frame.stack[frame.sp]) ?
              frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) :
              frame.pc += 3
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPLT
          (frame.stack[frame.sp - 1] < frame.stack[frame.sp]) ?
              frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) :
              frame.pc += 3
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPGE
          (frame.stack[frame.sp - 1] >= frame.stack[frame.sp]) ?
              frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) :
              frame.pc += 3
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPGT
          (frame.stack[frame.sp - 1] > frame.stack[frame.sp]) ?
              frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) :
              frame.pc += 3
          frame.sp -= 2
        when OpCodes::BYTE_IF_ICMPLE
          (frame.stack[frame.sp - 1] <= frame.stack[frame.sp]) ?
              frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) :
              frame.pc += 3
          frame.sp -= 2
        # -----------------------------------------------------------------------
        when OpCodes::BYTE__GOTO
          frame.pc += get_signed_branch_offset(byte_code[frame.pc+1, 2].join)
        when OpCodes::BYTE_JSR
          frame.sp += 1
          frame.stack[frame.sp] = frame.pc
          frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join)
        when OpCodes::BYTE_RET
          frame.pc = frame.locals[byte_code[frame.pc+1].to_i(16)]
        when OpCodes::BYTE_TABLESWITCH
          frame.pc = execute_table_switch(frame) + 1
        when OpCodes::BYTE_LOOKUPSWITCH
          frame.pc = execute_table_lookup_switch(frame) + 1
        # -------------------------- Return from methods -------------------------
        when OpCodes::BYTE_IRETURN, OpCodes::BYTE_LRETURN, OpCodes::BYTE_FRETURN, OpCodes::BYTE_DRETURN, OpCodes::BYTE_ARETURN
          MRjvm.debug('Return from function.')
          frame.sp -= 1
          return frame.stack[frame.sp+1]
        when OpCodes::BYTE__RETURN
          MRjvm.debug('Return from procedure.')
          return
        # -------------------------------- Fields --------------------------------
        when OpCodes::BYTE_GETSTATIC
          get_static_field(frame)
          frame.pc += 3
        when OpCodes::BYTE_PUTSTATIC
          put_static_field(frame)
          frame.pc += 3
        when OpCodes::BYTE_GETFIELD
          get_field(frame)
          frame.pc += 3
        when OpCodes::BYTE_PUTFIELD
          put_field(frame)
          frame.pc += 3
        # -------------------------- Invoking methods ----------------------------
        when OpCodes::BYTE_INVOKEVIRTUAL
          MRjvm.debug('Invoking virtual method.')
          execute_invoke(frame_stack, false)
          frame.pc += 3
        when OpCodes::BYTE_INVOKESPECIAL
          MRjvm.debug('Invoking special method.')
          execute_invoke(frame_stack, false)
          frame.pc += 3
        when OpCodes::BYTE_INVOKESTATIC
          MRjvm.debug('Invoking static method')
          execute_invoke(frame_stack, true)
          frame.pc += 3
        when OpCodes::BYTE_INVOKEINTERFACE
          MRjvm.debug('Invoking interface method')
          execute_interface_method(frame_stack)
          frame.pc += 5
        when OpCodes::BYTE_INVOKEDYNAMIC
          MRjvm.debug('Invoking dynamic method')
          execute_dynamic_method(frame_stack)
          frame.pc += 5
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
        when OpCodes::BYTE_ARRAYLENGTH
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_INT, object_heap.get_object(frame.stack[frame.sp]).values.length)
          frame.pc +=1
        # ------------------------------- Exceptions -------------------------------
        # when OpCodes::BYTE_ATHROW
        # -------------------------------------------------------------------------
        # when OpCodes::BYTE_CHECKCAST
        when OpCodes::BYTE_INSTANCEOF
          index = byte_code[frame.pc + 1, 2].join.to_i(16)
          object_pointer = frame.stack[frame.sp]
          object = object_heap.get_object(object_pointer);
          class_name = frame.java_class.get_from_constant_pool(frame.java_class.constant_pool[index-1][:name_index])
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_INT, object.type.this_class_str == class_name)
          frame.pc += 3
        # -------------------------- Thread synchronization -----------------------
        # when OpCodes::BYTE_MONITORENTER
        # when OpCodes::BYTE_MONITOREXIT
        # -------------------------------------------------------------------------
        # when OpCodes::BYTE_WIDE
        when OpCodes::BYTE_MULTIANEWARRAY
          # TODO Check if works.
          execute_new_a_multi_array(frame)
          frame.pc += 4
        # -------------------------------------------------------------------------
        when OpCodes::BYTE_IFNULL
          (frame.stack[sp].nil?) ? frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) : frame.pc += 3
          frame.sp -= 1
        when OpCodes::BYTE_IFNONNULL
          (!frame.stack[sp].nil?) ? frame.pc += get_signed_branch_offset(byte_code[frame.pc + 1, 2].join) : frame.pc += 3
          frame.sp -= 1
        # -------------------------------------------------------------------------
        when OpCodes::BYTE_GOTO_W
          frame.pc += get_signed_int_branch_offset(byte_code[frame.pc+1, 4].join)
        when OpCodes::BYTE_JSR_W
          frame.sp += 1
          frame.stack[frame.sp] = frame.pc
          frame.pc += get_signed_int_branch_offset(byte_code[frame.pc+1, 4].join)
        # -------------------------------------------------------------------------
        else
          raise StandardError, byte_code[frame.pc]
      end


      #@gc.run(object_heap, frame_stack, fp, '')
    end
    0
  end


  # -------------------------------------------------------------------------
  def get_signed_int_branch_offset(bytes)
    [bytes.scan(/[0-9a-f]{2}/i).reverse.join].pack('H*').unpack('l')[0]
  end

  def get_signed_branch_offset(bytes)
    [bytes.scan(/[0-9a-f]{2}/i).reverse.join].pack('H*').unpack('s')[0]
  end

  # -------------------------------------------------------------------------
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

  # -------------------------------------------------------------------------
  def put_field(frame)
    index = get_method_byte_code(frame)[frame.pc+1, 2].join('').to_i(16) - 1
    object_id = frame.stack[frame.sp - 1]
    value = frame.stack[frame.sp]

    MRjvm.debug("Putting value into field of object: #{object_id} on index: #{index} with value: #{value}.")

    var_list = object_heap.get_object(object_id).variables
    var_list[index] = value
    frame.sp -= 2
  end

  def get_field(frame)
    index = get_method_byte_code(frame)[frame.pc+1, 2].join('').to_i(16) - 1
    object_id = frame.stack[frame.sp]

    MRjvm.debug("Reading field from object: #{object_id} on index: #{index}.")

    var_list = object_heap.get_object(object_id).variables
    frame.stack[frame.sp] = var_list[index]
  end

  def put_static_field(frame)
    value = frame.stack[frame.sp]
    frame.sp -= 1

    index = get_method_byte_code(frame)[frame.pc+1, 2].join('').to_i(16) - 1
    frame.java_class.static_variables[index] = value

    MRjvm.debug("Putting value into static field of class: #{frame.java_class.this_class_str}, #{index}, #{value}.")
  end

  def get_static_field(frame)
    index = get_method_byte_code(frame)[frame.pc+1, 2].join('').to_i(16) - 1
    value = frame.java_class.static_variables[index]
    frame.sp += 1
    frame.stack[frame.sp] = value

    MRjvm.debug("Reading value from static field of class: #{frame.java_class.this_class_str}, #{index}.")
  end

  # -------------------------------------------------------------------------
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

  # -------------------------------------------------------------------------
  def execute_table_switch(frame)
    MRjvm.debug('Executing table switch.')

    index = frame.stack[frame.sp].value
    frame.sp -= 1
    byte_code = get_method_byte_code(frame)
    pc_offset = get_table_switch_padding_offset(frame)
    default_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    min_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    max_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    address_array = {}
    (min_value..max_value).each do |i|
      address_array[i.to_s.to_sym] = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
      pc_offset += 4
    end
    address_array[index.to_s.to_sym].nil? ? default_value : address_array[index.to_s.to_sym]
  end

  def get_table_switch_padding_offset(frame)
    4 - ((frame.pc) % 4)
  end

  def execute_table_lookup_switch(frame)
    MRjvm.debug('Executing table lookup switch.')

    index = frame.stack[frame.sp].value
    frame.sp -= 1
    byte_code = get_method_byte_code(frame)
    pc_offset = get_table_switch_padding_offset(frame)
    default_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    count = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    address_array = {}
    (0...count).each do |i|
      index_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
      pc_offset += 4
      address_array[index_value.to_s.to_sym] = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
      pc_offset += 4
    end
    address_array[index.to_s.to_sym].nil? ? default_value : address_array[index.to_s.to_sym]
  end

  # -------------------------------------------------------------------------
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

    @fp += 1
    return_value = execute(frame_stack)
    @fp -= 1

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

  # -------------------------------------------------------------------------
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

  def get_method_byte_code(frame)
    frame.method[:attributes][0][:code]
  end

  # -------------------------------------------------------------------------
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

  # -------------------------------------------------------------------------
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
    else
      'true_native'
    end
  end

  def get_locals_string(frame)
    locals_string = "[LOCALS]\n["
    frame.locals.each_with_index do |item, index|
      locals_string << "(#{index} => #{item}), "
    end
    locals_string << ']'
  end

  def get_stack_string(frame)
    stack_string = "[STACK]\n["
    frame.stack.each_with_index do |i, index|
      stack_string << "(#{index} => #{i}), "
    end
    stack_string << ']'
  end
end