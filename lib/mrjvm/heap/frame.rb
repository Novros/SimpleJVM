require_relative '../synchronization/synchronized_array'

module Heap
  # This class represents frame for functions calling.
  class Frame
    # pc = program_counter, sp = stack_pointer
    attr_accessor :java_class, :method, :pc, :sp, :stack, :locals

    @@stack_size= nil

    def initialize
      @java_class = nil
      @method = nil
      @pc = 0
      @sp = -1
      @stack = nil
      @locals = nil
    end

    def self::initialize_with_class_method(java_class, method, params_count)
      frame = Frame.new
      frame.java_class = java_class
      frame.method = method
      frame.stack = SynchronizedArray.new(@@stack_size, nil)
      frame.locals = SynchronizedArray.new(method[:attributes][0][:max_locals] + params_count, nil)
      frame
    end

    def self::initialize_with_class_native_method(java_class, method)
      frame = Frame.new
      frame.java_class = java_class
      frame.method = method
      frame.stack = SynchronizedArray.new(@@stack_size, nil)
      frame.locals = []
      frame
    end

    def self::stack_size
      @@stack_size
    end

    def self::stack_size=(size)
      @@stack_size = size
    end

    # Synchronized access to stack pointer
    def sp=(value)
      MRjvm::MRjvm.mutex.synchronize do
        @sp = value
      end
    end
  end
end
