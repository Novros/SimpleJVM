require_relative 'tag_reader'

module MethodConstantReader
  def read_method_type
    method_type = {}
    method_type[:tag] = TagReader::CONSTANT_METHOD_TYPE
    method_type[:descriptor_index] = load_bytes(2).to_i(16)
    method_type
  end

  def read_method_handle
    method_handle = {}
    method_handle[:tag] = TagReader::CONSTANT_METHOD_HANDLE
    method_handle[:reference_kind] = load_bytes(1).to_i(16)
    method_handle[:reference_index] = load_bytes(2).to_i(16)
    method_handle
  end
end
