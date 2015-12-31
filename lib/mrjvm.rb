require 'mrjvm/version'
require 'mrjvm/class_file/java_class'
require 'mrjvm/heap/class_heap'
require 'mrjvm/heap/object_heap'
require 'mrjvm/heap/frame'
require 'mrjvm/execution_core'

module MRjvm
  DEBUG_STRING = '[DEBUG] '
  FRAME_STACK_SIZE = 20
  OPERAND_STACK_SIZE = 100

  ##
  # Debug function if DEBUG is true.
  def self::debug(string)
    puts DEBUG_STRING + string + "\n" if DEBUG
  end

  ##
  # Entry point class.
  class MRjvm

    ##
    # Print class file to output.
    def self::print_file(file)
      reader = ClassFileReader.new(file)
      reader.parse_content
      puts reader.class_file
    end

    ##
    # Run file with class Main and function main.
    def self::run(file)
      # TODO File is not used, because of testing
      class_heap = Heap::ClassHeap.new
      java_class = class_heap.load_class('Factorial')
      class_heap.load_class('java/lang/Object')

      object_heap = Heap::ObjectHeap.new

      frame_stack = []
      FRAME_STACK_SIZE.times do
        frame_stack.push(Heap::Frame.new)
      end
      Heap::Frame.op_stack = Array.new(OPERAND_STACK_SIZE, nil)

      object_id = object_heap.create_object(java_class) # Create instance. # TODO Entry function must be static.
      method_index = java_class.get_method_index('entry') # Here must be name of method, which will be started.

      start_frame = frame_stack[0]
      start_frame.frame_class = java_class
      start_frame.method = java_class.methods[method_index]
      start_frame.stack = Heap::Frame.op_stack
      start_frame.sp = start_frame.method[:attributes][0][:max_locals]
      start_frame.stack[0] = object_id
      start_frame.pc = 0

      executing_core = ExecutionCore.new
      executing_core.class_heap = class_heap
      executing_core.object_heap = object_heap
      executing_core.fp = 0
      executing_core.execute(frame_stack)
    end
  end
end
