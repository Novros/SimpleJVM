module Heap
  class Frame
    # pc = program_counter, sp = stack_pointer
    attr_accessor :java_class, :method, :pc, :sp, :stack, :locals

    @@op_stack = nil

    def initialize
      @java_class = nil
      @method = nil
      @pc = 0
      @sp = -1
      @stack = nil
      @locals = nil
    end

    def self::initialize_with_class_method(java_class, method)
      frame = Frame.new
      frame.java_class = java_class
      frame.method = method
      frame.stack = @@op_stack
      frame.locals = Array.new(method[:attributes][0][:max_locals], nil)
      frame
    end

    def self::initialize_with_class_native_method(java_class, method)
      frame = Frame.new
      frame.java_class = java_class
      frame.method = method
      frame.stack = @@op_stack
      frame.locals = []
      frame
    end

    def self::op_stack
      @@op_stack
    end

    def self::op_stack=(op_stack)
      @@op_stack = op_stack
    end

  end
end