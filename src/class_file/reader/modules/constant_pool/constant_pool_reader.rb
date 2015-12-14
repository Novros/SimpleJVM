require_relative  'tag_reader'
require_relative 'reference_reader'
require_relative 'class_info_reader'
require_relative 'invoke_dynamic_reader'
require_relative 'method_constant_reader'
require_relative 'name_and_type_reader'
require_relative 'primitive_reader'
require_relative 'utf8_reader'

class ConstantPoolReaderError < StandardError
end

module ConstantPoolReader
  include TagReader
  include ReferenceReader
  include ClassInfoReader
  include InvokeDynamicReader
  include MethodConstantReader
  include NameAndTypeReader
  include PrimitiveReader
  include UTF8Reader

  def read_constant_pool
    @class_file.constant_pool_count = load_bytes(2).to_i(16)

    (@class_file.constant_pool_count-1).times do |index|
      constant_tag = read_constant_tag
      case constant_tag
        when TagReader::CONSTANT_METHODREF
          constant = read_method_ref
        when TagReader::CONSTANT_INTERFACE_METHODREF
          constant = read_interface_methodref
        when TagReader::CONSTANT_FIELDREF
          constant = read_field_ref
        when TagReader::CONSTANT_CLASS
          constant = read_class_info
        when TagReader::CONSTANT_INVOKE_DYNAMIC
          constant = read_invoke_dynamic
        when TagReader::CONSTANT_METHOD_HANDLE
          constant = read_method_handle
        when TagReader::CONSTANT_METHOD_TYPE
          constant = read_method_type
        when TagReader::CONSTANT_NAME_AND_TYPE
          constant = read_name_and_type
        when TagReader::CONSTANT_INTEGER
          constant = read_integer
        when TagReader::CONSTANT_STRING
          constant = read_string
        when TagReader::CONSTANT_DOUBLE
          constant = read_double
        when TagReader::CONSTANT_FLOAT
          constant = read_float
        when TagReader::CONSTANT_LONG
          constant = read_long
        when TagReader::CONSTANT_UTF8
          constant = read_utf8
        else
          fail ConstantPoolReaderError, 'Undefined constant pool tag; found: ' + constant_tag.to_s
      end
      constant['#'] = index+1
      @class_file.constant_pool << constant
    end

  end
end
