module Heap
  class Frame
    # pc = program_counter, sp = stack_pointer
    attr_accessor :frame_class, :method, :pc, :sp, :stack

    @@base_frame = nil
    @@op_stack = nil

    def initialize
      @sp = -1
      @frame_class = nil
      @pc = 0
      @stack = nil
    end

    def self::initialize_with_sp(sp)
      frame = Frame.new
      frame.sp = sp
      frame.frame_class = nil
      frame.pc = 0
      frame.stack = nil
      frame
    end

    def self::base_frame
      @@base_frame
    end

    def self::base_frame=(base_frame)
      @@base_frame = base_frame
    end

    def self::op_stack
      @@op_stack
    end

    def self::op_stack=(op_stack)
      @@op_stack = op_stack
    end

  end
end