
module Native
  class RuntimeEnvironment
    attr_accessor :frame_stack, :class_heap, :object_heap, :critical_section

    def run(native)
      self.method(native.to_sym).call(self)
    end


    def native_print(rte)
      frame = rte.frame_stack[0]
      object = frame.stack[frame.sp]
      variable = rte.object_heap.get_object(object)
      puts variable.variables[1]
    end
  end

end