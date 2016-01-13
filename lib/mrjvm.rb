require 'mrjvm/version'
require 'mrjvm/class_file/java_class'
require 'mrjvm/heap/class_heap'
require 'mrjvm/heap/object_heap'
require 'mrjvm/heap/frame'
require 'mrjvm/heap/stack_variable'
require 'mrjvm/execution_core/execution_core'
require_relative 'mrjvm/garbage_collector/garbage_collector'
require_relative 'mrjvm/synchronization/synchronized_array'

class MRjvmError < RuntimeError
end

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
    attr_accessor :op_size, :frame_size, :native_lib_path

    @@mutex = Mutex.new

    def self::mutex
      @@mutex
    end

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
    def run(file, arguments)
      class_heap = Heap::ClassHeap.new
      class_heap.native_lib_path = native_lib_path unless native_lib_path.nil?
      object_heap = Heap::ObjectHeap.new

      # Load entry point class.
      java_class = class_heap.load_class_from_file(file)
      # Load std classes in java/lang/.
      load_std_classes(class_heap)

      frame_stack = SynchronizedArray.new
      @frame_size.times do
        frame_stack.push(Heap::Frame.new)
      end
      Heap::Frame.stack_size = @op_size

      method_index = java_class.get_method_index('main', '([Ljava/lang/String;)V', true)
      fail StandardError, 'Class not contains static method main!' if method_index == -1

      frame_stack[0] = Heap::Frame.initialize_with_class_method(java_class, java_class.methods[method_index], 0) # No parameters
      args_pointer = create_args(arguments, class_heap, object_heap)
      frame_stack[0].locals[0] = args_pointer

      executing_core = ExecutionCore.new
      executing_core.class_heap = class_heap
      executing_core.object_heap = object_heap
      executing_core.fp = 0

      gc = GarbageCollector.new
      # Start garbage collector
      gc.run(executing_core, frame_stack)
      # Execute java code
      executing_core.execute(frame_stack)
      # Set stop attribute as true
      gc.stop_gc = true
    end

    def load_std_classes(class_heap)
      class_heap.load_class('java/lang/Object')
      class_heap.load_class('java/lang/String')
      class_heap.load_class('java/lang/StringBuilder')
      class_heap.load_class('java/lang/System')
    end

    def create_args(arguments, class_heap, object_heap)
      array_pointer = object_heap.create_new_array(Heap::VARIABLE_STRING, Heap::StackVariable.new(Heap::VARIABLE_INT, arguments.size))
      array = object_heap.get_object(array_pointer)
      arguments.each_with_index do |arg, index|
         array.variables[index] = object_heap.create_string_object(arg, class_heap);
      end
      array_pointer
    end
  end
end
