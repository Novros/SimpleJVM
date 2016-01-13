require_relative '../../mrjvm'
require 'thread'
require 'set'

class GarbageCollector
  # Number of seconds, when garbage collector check object heap
  TIMEOUT = 0.5

  attr_accessor :stop_gc

  # Start garbage collector
  def run(execution_core, frame_stack)
    MRjvm.debug('Garbage collector started')

    @object_heap = execution_core.object_heap
    @class_heap = execution_core.class_heap
    # if JVM set this variable as true, GC thread will be automatically stopped
    @stop_gc = false

    Thread.new do
      execute_code_every(TIMEOUT) do
        # mutex access shared variables
        MRjvm::MRjvm.mutex.synchronize do
          # this array contains references to live objects
          # all items are heap_id of object instance
          @live_objects = Set.new
          check_object_heap
          check_frame_stack(frame_stack, execution_core.fp)
          check_class_variables
          clear_garbage
        end
        # stop garbage collector when all objects were deleted
        @stop_gc && Thread.stop
      end

    end
  end

  def check_class_variables
    @class_heap.each do |class_map|
      check_java_static_variables(class_map[1])
    end
  end

  def check_java_static_variables(java_class)
    java_class.static_variables.each do |object_variable|
      check_stack_variable(object_variable)
    end
  end

  # Find object references in object variables
  def check_object_heap
    @object_heap.each do |object_map|
      check_object_variables(object_map[1])
    end
  end

  # Iterate object variables and check it for life objects
  def check_object_variables(object)
    object.variables.each do |object_variable|
      check_stack_variable(object_variable)
    end
  end

  # Find object references in frame stack and locals
  # frame pointer is pointer to frame_stack last valid element
  def check_frame_stack(frame_stack, frame_pointer)
    for fp in 0..frame_pointer
      frame = frame_stack[fp]

      # frame.sp is pointer to frame.stack last valid element
      for sp in 0..frame.sp
        check_stack_variable(frame.stack[sp])
      end
      frame.locals.each do |local_item|
        check_stack_variable(local_item)
      end
    end
  end

  # Check if given stack_variable is object, if yes add to live object array
  def check_stack_variable(stack_variable)
    if !stack_variable.nil? && stack_variable.object?
      ret = @live_objects.add?(stack_variable.value)
      unless ret.nil?
        # call recursively on objects of object
        object = @object_heap.get_object(stack_variable)
        (check_object_variables(object)) unless object.nil?
      end
    end
  end

  # Iterate live object and remove dead objects (without reference)
  def clear_garbage
    MRjvm.debug('Live Objects: ' << @live_objects.to_s)
    @object_heap.each do |object_map|
      !@live_objects.include?(object_map[1].heap_id) &&
          (@object_heap.remove_object(object_map[1]))
    end
  end

  # Execute same code every seconds
  def execute_code_every(seconds)
    last_tick = Time.now
    loop do
      sleep 0.1
      if Time.now - last_tick >= seconds
        last_tick += seconds
        yield
      end
    end
  end
end
