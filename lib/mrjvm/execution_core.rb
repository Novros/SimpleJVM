require_relative 'class_file/reader/modules/access_flags_reader'
require_relative 'heap/frame'
require_relative 'op_codes'

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# TODO This is only for showing the logic of execution, rewrite
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
class ExecutionCore
  attr_accessor :class_heap, :object_heap

  def execute(frame_stack)
    frame = frame_stack[0]

    if frame.method.access_flags & AccessFlagsReader::ACC_SYNTHETIC
      execute_native_method(frame)
      return 0
    end

    # TODO Rewrite, this is only for logic
    byte_counter = frame.method.attributes.code + frame.pc
    java_class = frame.frame_class
    method_string = java_class.get_string_from_constant_pool(frame.method.name_index)

    # TODO Some debug things
    while(true)
      case byte_counter[frame.pc]
        when BYTE_NOP
          frame.pc += 1
        when BYTE_IADD
          frame.stack[frame.sp-1].intValue = frame.stack[frame.sp-1].intValue + frame.stack[frame.sp].intValue
          frame.sp -= 1
          frame.pc += 1
          # TODO Add other instructions.
        else
      end
    end
    return 0
  end

  def execute_native_method(frame)

  end
end