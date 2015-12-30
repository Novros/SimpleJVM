
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
  end

end