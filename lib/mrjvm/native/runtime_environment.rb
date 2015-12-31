
module Native
  class RuntimeEnvironment
    attr_accessor :frame_stack, :class_heap, :object_heap, :critical_section, :fp

    def run(native)
      self.method(native.to_sym).call(self)
    end

    def native_print(rte)
      frame = rte.frame_stack[fp]
      this_object = frame.stack[frame.sp]
      if this_object.is_a?(Heap::ObjectPointer)
        this_object = object_heap.get_object(this_object)
        puts this_object.variables[0]
      else
        puts this_object
      end
      0
    end

    def string_builder_append_i(rte)
      frame = rte.frame_stack[fp]
      this_object = frame.stack[frame.sp - 1]
      value = frame.stack[frame.sp]
      this_object = object_heap.get_object(this_object)
      if this_object.variables[0].nil?
        this_object.variables[0] = ''
      end
      this_object.variables[0] = this_object.variables[0] + value.to_s
      Heap::ObjectPointer.new(this_object.heap_id)
    end

    def string_builder_append_s(rte)
      frame = rte.frame_stack[fp]
      this_object = frame.stack[frame.sp - 1]
      value = frame.stack[frame.sp]
      this_object = object_heap.get_object(this_object)
      if this_object.variables[0].nil?
        this_object.variables[0] = ''
      end
      this_object.variables[0] = this_object.variables[0] + value.to_s
      Heap::ObjectPointer.new(this_object.heap_id)
    end

    def string_builder_to_string_string(rte)
      frame = rte.frame_stack[fp]
      this_object = frame.stack[frame.sp]
      this_object = object_heap.get_object(this_object)
      object_heap.create_string_object(this_object.variables[0], class_heap)
    end
  end

end