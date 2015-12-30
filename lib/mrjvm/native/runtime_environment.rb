
module Native
  class RuntimeEnvironment
    attr_accessor :frame_stack, :class_heap, :object_heap, :critical_section, :fp

    def run(native)
      self.method(native.to_sym).call(self)
    end

    def native_print(rte)
      frame = rte.frame_stack[fp]
      puts frame.stack[frame.sp-1]
      0
      # variable = rte.object_heap.get_object(object_id)
      #puts variable.variables[1]
    end

    def string_builder_append_i(rte)
      # TODO implement
      frame = rte.frame_stack[fp]
      this_object = frame.stack[0]
      value = frame.stack[frame.sp]
      this_object = object_heap.get_object(this_object)
      # raise StandardError, 'BAD class, it must be string builder.' unless this_object.variables[0].this_class_str.include? 'StringBuilder'
      if this_object.variables[1].nil?
        this_object.variables[1] = ''
      end
      this_object.variables[1] = this_object.variables[1] + value.to_s
      this_object.heap_id
    end

    def string_builder_to_string_string(rte)
      # TODO implement
      frame = rte.frame_stack[fp]
      this_object = frame.stack[0]
      value = frame.stack[frame.sp]
      puts value.to_s
      this_object = object_heap.get_object(this_object)
      # raise StandardError, 'BAD class, it must be string builder.' unless this_object.variables[0].this_class_str.include? 'StringBuilder'
      if this_object.variables[1].nil?
        this_object.variables[1] = ''
      end
      object_heap.create_string_object(this_object.variables[1], class_heap)
    end
  end

end