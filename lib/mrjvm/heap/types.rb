module Heap

  CHAR_VALUE = 1
  SHORT_VALUE = 2
  INT_VALUE = 3
  FLOAT_VALUE = 4
  POINTER_VALUE = 5
  OBJECT_VALUE = 6

  class Object
    attr_accessor :heap_id, :type
  end
end