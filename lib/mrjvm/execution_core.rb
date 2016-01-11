require_relative 'class_file/reader/modules/access_flags_reader'
require_relative 'heap/frame'
require_relative 'heap/class_heap'
require_relative 'heap/object_heap'
require_relative 'op_codes'
require_relative 'native/native_runner'

require_relative 'execution_core/execution_core_fields'
require_relative 'execution_core/execution_core_methods'
require_relative 'execution_core/execution_core_new'
require_relative 'execution_core/execution_core_switch'
require_relative 'execution_core/execution_core_native'
require_relative 'execution_core/execution_core_debug'
require_relative 'execution_core/execution_core_throw'

class ExecutionCore
  # fp = frame pointer
  attr_accessor :class_heap, :object_heap, :fp

  # -------------------------------------------------------------------------
  include ExecutionCoreFields
  include ExecutionCoreNew
  include ExecutionCoreMethods
  include ExecutionCoreSwitch
  include ExecutionCoreNative
  include ExecutionCoreDebug
  include ExecutionCoreThrow

  # -------------------------------------------------------------------------
  def initialize
    @stack_var_zero = Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
    @gc = GarbageCollector.new
    # Start garbage collector
  end

  # -------------------------------------------------------------------------
  # Synchronized access to frame pointer
  def fp=(value)
    MRjvm::MRjvm.mutex.synchronize do
      @fp = value
    end
  end

  # -------------------------------------------------------------------------
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
          # care on signed integer
          int_number = byte_code[frame.pc+1].to_i(16)
          int_number > 127 && (int_number = int_number - 256)
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_INT, int_number)
          frame.pc += 2
        when OpCodes::BYTE_SIPUSH
          frame.sp += 1
          # care on signed short
          frame.stack[frame.sp] = Heap::StackVariable.new(Heap::VARIABLE_SHORT, get_signed_branch_offset(byte_code[frame.pc+1, 2].join('')))
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
          frame.stack[frame.sp] = frame.locals[byte_code[frame.pc+1].to_i(16)].clone
          frame.pc += 2
        when OpCodes::BYTE_ILOAD_0, OpCodes::BYTE_ILOAD_1, OpCodes::BYTE_ILOAD_2, OpCodes::BYTE_ILOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_ILOAD_0].clone
          frame.pc += 1
        when OpCodes::BYTE_LLOAD_0, OpCodes::BYTE_LLOAD_1, OpCodes::BYTE_LLOAD_2, OpCodes::BYTE_LLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_LLOAD_0].clone
          frame.pc += 1
        when OpCodes::BYTE_FLOAD_0, OpCodes::BYTE_FLOAD_1, OpCodes::BYTE_FLOAD_2, OpCodes::BYTE_FLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_FLOAD_0].clone
          frame.pc += 1
        when OpCodes::BYTE_DLOAD_0, OpCodes::BYTE_DLOAD_1, OpCodes::BYTE_DLOAD_2, OpCodes::BYTE_DLOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_DLOAD_0].clone
          frame.pc += 1
        when OpCodes::BYTE_ALOAD_0, OpCodes::BYTE_ALOAD_1, OpCodes::BYTE_ALOAD_2, OpCodes::BYTE_ALOAD_3
          frame.sp += 1
          frame.stack[frame.sp] = frame.locals[byte_code_int - OpCodes::BYTE_ALOAD_0].clone
          frame.pc += 1
        when OpCodes::BYTE_IALOAD, OpCodes::BYTE_LALOAD, OpCodes::BYTE_FALOAD, OpCodes::BYTE_DALOAD, OpCodes::BYTE_AALOAD, OpCodes::BYTE_BALOAD, OpCodes::BYTE_CALOAD, OpCodes::BYTE_SALOAD
          frame.stack[frame.sp-1] = object_heap.get_value_from_array(frame.stack[frame.sp-1], frame.stack[frame.sp].value)
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_ISTORE, OpCodes::BYTE_LSTORE, OpCodes::BYTE_FSTORE, OpCodes::BYTE_DSTORE, OpCodes::BYTE_ASTORE
          frame.locals[byte_code[frame.pc+1].to_i(16)] = frame.stack[frame.sp].clone
          frame.sp -= 1
          frame.pc += 2
        when OpCodes::BYTE_ISTORE_0, OpCodes::BYTE_ISTORE_1, OpCodes::BYTE_ISTORE_2, OpCodes::BYTE_ISTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_ISTORE_0] = frame.stack[frame.sp].clone
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_LSTORE_0, OpCodes::BYTE_LSTORE_1, OpCodes::BYTE_LSTORE_2, OpCodes::BYTE_LSTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_LSTORE_0] = frame.stack[frame.sp].clone
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_FSTORE_0, OpCodes::BYTE_FSTORE_1, OpCodes::BYTE_FSTORE_2, OpCodes::BYTE_FSTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_FSTORE_0] = frame.stack[frame.sp].clone
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_DSTORE_0, OpCodes::BYTE_DSTORE_1, OpCodes::BYTE_DSTORE_2, OpCodes::BYTE_DSTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_DSTORE_0] = frame.stack[frame.sp].clone
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_ASTORE_0, OpCodes::BYTE_ASTORE_1, OpCodes::BYTE_ASTORE_2, OpCodes::BYTE_ASTORE_3
          frame.locals[byte_code_int - OpCodes::BYTE_ASTORE_0] = frame.stack[frame.sp].clone
          frame.sp -= 1
          frame.pc += 1
        when OpCodes::BYTE_IASTORE, OpCodes::BYTE_LASTORE, OpCodes::BYTE_FASTORE, OpCodes::BYTE_DASTORE, OpCodes::BYTE_AASTORE, OpCodes::BYTE_BASTORE, OpCodes::BYTE_CASTORE, OpCodes::BYTE_SASTORE
          frame.sp -= 3
          object_heap.get_object(frame.stack[frame.sp+1]).variables[frame.stack[frame.sp+2].value] = frame.stack[frame.sp+3].clone
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
          frame.stack[frame.sp+1] = frame.stack[frame.sp].clone
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
          frame.stack[frame.sp-1] = Heap::StackVariable.new(Heap::VARIABLE_INT, frame.stack[frame.sp-1] <=> frame.stack[frame.sp])
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
          execute_virtual_method(frame_stack)
          frame.pc += 3
        when OpCodes::BYTE_INVOKESPECIAL
          MRjvm.debug('Invoking special method.')
          execute_special_method(frame_stack)
          frame.pc += 3
        when OpCodes::BYTE_INVOKESTATIC
          MRjvm.debug('Invoking static method')
          execute_static_method(frame_stack)
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
        when OpCodes::BYTE_ATHROW
          execute_throw(object_heap, frame_stack, fp)
          frame.pc += 1
        # -------------------------------------------------------------------------
        when OpCodes::BYTE_CHECKCAST
          frame.pc += 3
        when OpCodes::BYTE_INSTANCEOF
          index = byte_code[frame.pc + 1, 2].join.to_i(16)
          object_pointer = frame.stack[frame.sp]
          object = object_heap.get_object(object_pointer)
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

  def get_method_byte_code(frame)
    frame.method[:attributes][0][:code]
  end
end