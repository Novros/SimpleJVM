require_relative 'tag_reader'

module ReferenceReader
  def read_method_ref
    method_ref = read_ref
    method_ref[:tag] = TagReader::CONSTANT_METHODREF
    method_ref
  end

  def read_field_ref
    field_ref = read_ref
    field_ref[:tag] = TagReader::CONSTANT_FIELDREF
    field_ref
  end

  def read_interface_methodref
    interface_ref = read_ref
    interface_ref[:tag] = TagReader::CONSTANT_INTERFACE_METHODREF
    interface_ref
  end

  private
  def read_ref
    ref = {}
    ref[:class_index] = load_bytes(2).to_i(16)
    ref[:name_and_type_index] = load_bytes(2).to_i(16)
    ref
  end
end