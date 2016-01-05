module Heap
  VARIABLE_SHORT = 0
  VARIABLE_INT = 1
  VARIABLE_LONG = 2
  VARIABLE_FLOAT = 3
  VARIABLE_DOUBLE = 4
  VARIABLE_CHAR = 5
  VARIABLE_STRING = 6
  VARIABLE_OBJECT = 7
  VARIABLE_ARRAY = 8
  VARIABLE_BYTE = 9

  # This class is stored in operand stack
  class StackVariable
    attr_accessor :type, :value

    def initialize(type, value)
      @type = type
      @value = value
    end

    def <(other)
      value < other.value
    end

    def <=(other)
      value <= other.value
    end

    def >(other)
      value > other.value
    end

    def >=(other)
      value >= other.value
    end

    def ==(other)
     value == other.value
    end

    def !=(other)
     value != other.value
    end

    def <=>(other)
      value <=> other.value
    end

    def +(other)
      StackVariable.new(@type, value + other.value)
    end

    def -(other)
      StackVariable.new(@type, value - other.value)
    end

    def *(other)
      StackVariable.new(@type, value * other.value)
    end

    def /(other)
      StackVariable.new(@type, value / other.value)
    end

    def %(other)
      StackVariable.new(@type, value % other.value)
    end

    def !
      StackVariable.new(@type, !value)
    end

    def &(other)
      StackVariable.new(@type, value & other.value)
    end

    def |(other)
      StackVariable.new(@type, value | other.value)
    end

    def ^(other)
      StaackVariable.new(@type, value ^ other.value)
    end

    def <<(other)
      StackVariable.new(@type, value << other)
    end

    def >>(other)
      StackVariable.new(@type, value >> other)
    end

    def to_s
      "{type#{type}:#{value}}"
    end

    # check if object variable refers to object
    def object?
      @type == VARIABLE_OBJECT || @type == VARIABLE_ARRAY || @type == VARIABLE_STRING
    end
  end
end
