module Heap
  class Frame
    # pc = program_counter, sp = stack_pointer
    attr_accessor :op_stack, :base_frame, :frame_class, :method, :pc, :sp, :stack

    def initialize
      @sp = -1
      @frame_class = nil
      @pc = 0
      @stack = nil
      @base_frame = nil
      @op_stack = nil
    end

    def self::initialize_with_sp(sp)
      frame = Frame.new
      frame.sp = sp
      frame.frame_class = nil
      frame.pc = 0
      frame.stack = nil
      frame
    end
  end
end