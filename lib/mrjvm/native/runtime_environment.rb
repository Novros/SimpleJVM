require_relative '../heap/object_heap'

module Native
  class RuntimeEnvironment
    attr_accessor :frame_stack, :class_heap, :object_heap, :critical_section, :fp

    def run(native)
      self.method(native.to_sym).call(self)
    end

    def native_print(rte)
      frame = rte.frame_stack[fp]
      stack_variable = frame.stack[frame.sp]
      if stack_variable.type == Heap::VARIABLE_OBJECT
        object = object_heap.get_object(stack_variable)
        puts object.variables[0]
      else
        puts stack_variable.value
      end
      Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
    end

    def string_builder_append_i(rte)
      frame = rte.frame_stack[fp]
      object_pointer = frame.stack[frame.sp - 1]
      value = frame.stack[frame.sp]
      object = object_heap.get_object(object_pointer)
      if object.variables[0].nil?
        object.variables[0] = ''
      end
      object.variables[0] = object.variables[0] + value.value.to_s
      Heap::StackVariable.new(Heap::VARIABLE_OBJECT, object.heap_id)
    end

    def string_builder_append_s(rte)
      frame = rte.frame_stack[fp]
      object_pointer = frame.stack[frame.sp - 1]
      value = frame.stack[frame.sp]
      object = object_heap.get_object(object_pointer)
      if object.variables[0].nil?
        object.variables[0] = ''
      end
      object.variables[0] = object.variables[0] + value.value.to_s
      Heap::StackVariable.new(Heap::VARIABLE_OBJECT, object.heap_id)
    end

    def string_builder_to_string_string(rte)
      frame = rte.frame_stack[fp]
      object_pointer = frame.stack[frame.sp]
      object = object_heap.get_object(object_pointer)
      object_heap.create_string_object(object.variables[0], class_heap)
    end
  end

end