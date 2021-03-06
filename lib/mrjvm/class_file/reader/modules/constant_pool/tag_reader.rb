module TagReader

  CONSTANT_CLASS = 7
  CONSTANT_FIELDREF = 9
  CONSTANT_METHODREF = 10
  CONSTANT_INTERFACE_METHODREF = 11
  CONSTANT_STRING = 8
  CONSTANT_INTEGER = 3
  CONSTANT_FLOAT = 4
  CONSTANT_LONG = 5
  CONSTANT_DOUBLE = 6
  CONSTANT_NAME_AND_TYPE = 12
  CONSTANT_UTF8 = 1
  CONSTANT_METHOD_HANDLE = 15
  CONSTANT_METHOD_TYPE = 16
  CONSTANT_INVOKE_DYNAMIC = 18

  def read_constant_tag
    load_bytes(1).to_i(16)
  end
end
