require 'mrjvm/version'
require 'mrjvm/class_file/java_class'
require 'mrjvm/heap/class_heap'
require 'mrjvm/heap/object_heap'
require 'mrjvm/heap/frame'
require 'mrjvm/execution_core'

# MRjvm is main module of our JVM.
module MRjvm
  DEBUG_STRING = '[DEBUG] '

  ##
  # Debug function if DEBUG is true.
  def self::debug(string)
    puts DEBUG_STRING + string + "\n" if DEBUG
  end

  ##
  # Entry point class.
  class MRjvm
    attr_accessor :op_size, :frame_size

    def initialize
      @op_size = 100
      @frame_size = 20
    end

    ##
    # Print class file to output.
    def print_file(file)
      reader = ClassFileReader.new(file)
      reader.parse_content
      puts reader.class_file
    end

    ##
    # Run file with class Main and function main.
    def run(file)
      class_heap = Heap::ClassHeap.new
      object_heap = Heap::ObjectHeap.new

      # Load entry point class.
      java_class = class_heap.load_class_from_file(file)
      # Load object class.
      class_heap.load_class('java/lang/Object')

      frame_stack = []
      @frame_size.times do
        frame_stack.push(Heap::Frame.new)
      end
      Heap::Frame.op_stack = Array.new(@op_size, nil)

      method_index = java_class.get_method_index('main', '()V', true)
      fail StandardError, 'Class not contains static method main!' if method_index == -1

      frame_stack[0] = Heap::Frame.initialize_with_class_method(java_class, java_class.methods[method_index], 0) # No parameters
      start_frame = frame_stack[0]
      start_frame.locals[0] = object_id

      executing_core = ExecutionCore.new
      executing_core.class_heap = class_heap
      executing_core.object_heap = object_heap
      executing_core.fp = 0
      executing_core.execute(frame_stack)
    end
  end
end
