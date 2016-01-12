module NativeRunTypes
  def get_method_argument_types(method_descriptor)
    # First two types: JNIenv, jobject
    types = [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
    i = 1
    while i < method_descriptor.size
      break if method_descriptor[i] == ')'
      types << case method_descriptor[i]
               when 'B', 'C'
                 Fiddle::TYPE_CHAR
               when 'S'
                 Fiddle::TYPE_SHORT
               when 'I'
                 Fiddle::TYPE_INT
               when 'J'
                 Fiddle::TYPE_LONG
               when 'F'
                 Fiddle::TYPE_FLOAT
               when 'D'
                 Fiddle::TYPE_DOUBLE
               when 'L'
                 i += 1 until method_descriptor[i] == ';'
                 Fiddle::TYPE_VOIDP
               when '['
                 i += 1 until method_descriptor[i] == '['
                 i += 1
                 Fiddle::TYPE_VOIDP
               end
      i += 1
    end
    types
  end

  def get_method_return_type(method_descriptor)
    type = nil
    for i in 1..method_descriptor.size
      if method_descriptor[i - 1] == ')'
        type = case method_descriptor[i]
               when 'B', 'C'
                 Fiddle::TYPE_CHAR
               when 'S'
                 Fiddle::TYPE_SHORT
               when 'I'
                 Fiddle::TYPE_INT
               when 'J'
                 Fiddle::TYPE_LONG
               when 'F'
                 Fiddle::TYPE_FLOAT
               when 'D'
                 Fiddle::TYPE_DOUBLE
               when 'L', '['
                 Fiddle::TYPE_VOIDP
               else
                 Fiddle::TYPE_VOID
               end
        break
      end
    end
    type
  end

  def get_method_return_stack_type(method_descriptor)
    type = nil
    for i in 1..method_descriptor.size
      if method_descriptor[i - 1] == ')'
        type = case method_descriptor[i]
               when 'B'
                 Heap::VARIABLE_BYTE
               when 'C'
                 Heap::VARIABLE_CHAR
               when 'S'
                 Heap::VARIABLE_SHORT
               when 'I'
                 Heap::VARIABLE_INT
               when 'J'
                 Heap::VARIABLE_LONG
               when 'F'
                 Heap::VARIABLE_FLOAT
               when 'D'
                 Heap::VARIABLE_DOUBLE
               when 'L', '['
                 Heap::VARIABLE_OBJECT
               else
                 Heap::VARIABLE_INT
               end
        break
      end
    end
    type
  end
end