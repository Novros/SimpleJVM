require_relative 'code_attribute_reader'
require_relative 'constant_attribute_reader'
require_relative 'exception_attribute_reader'
require_relative 'line_number_table_attribute_reader'
require_relative 'local_variable_table_attribute'
require_relative 'stack_map_table_attribute_reader'
require_relative 'signature_attribute_reader'
require_relative 'source_file_attribute_reader'

class AttributeReaderError < StandardError
end

module AttributesReader
  ATTRIBUTE_CONSTANT = 'ConstantValue'
  ATTRIBUTE_CODE = 'Code'
  ATTRIBUTE_EXCEPTIONS = 'Exceptions'
  ATTRIBUTE_LINE_NUMBER_TABLE = 'LineNumberTable'
  ATTRIBUTE_LOCAL_VARIABLE_TABLE = 'LocalVariableTable'
  ATTRIBUTE_STACK_MAP_TABLE = 'StackMapTable'
  ATTRIBUTE_SIGNATURE = 'Signature'
  ATTRIBUTE_SOURCE_FILE = 'SourceFile'

  include CodeAttributeReader
  include ExceptionAttributeReader
  include ConstantAttributeReader
  include LineNumberTableAttributeReader
  include LocalVariableTableAttribute
  include StackMapTableAttributeReader
  include SignatureAttributeReader
  include SourceFileAttributeReader

  def read_attributes(attributes_count = nil)
    attributes_count.nil? &&
      (attributes_count = load_bytes(2).to_i(16))

    attributes = []
    attributes_count.times do
      attribute_name_index = load_bytes(2).to_i(16)
      attribute_name = @class_file.constant_pool[attribute_name_index-1][:bytes]
      puts attribute_name
      case attribute_name
        when ATTRIBUTE_CODE
          attributes << read_code_attribute(attribute_name_index)
        when ATTRIBUTE_CONSTANT
          attributes << read_constant_attribute(attribute_name_index)
        when ATTRIBUTE_EXCEPTIONS
          attributes << read_exception_attribute(attribute_name_index)
        when ATTRIBUTE_LINE_NUMBER_TABLE
          attributes << read_line_number_table_attribute(attribute_name_index)
        when ATTRIBUTE_LOCAL_VARIABLE_TABLE
          attributes << read_local_variable_table_attribute(attribute_name_index)
        when ATTRIBUTE_STACK_MAP_TABLE
          attributes << read_stack_map_table_attribute(attribute_name_index)
        when ATTRIBUTE_SIGNATURE
          attributes << read_signature_attribute(attribute_name_index)
        when ATTRIBUTE_SOURCE_FILE
          attributes << read_source_file_attribute(attribute_name_index)
        else
          fail AttributeReaderError, 'non existing attribute name; index: ' +
                                     attribute_name_index.to_s + '; name: ' + attribute_name.to_s +
                                     '; next bytes: ' + load_bytes(8)
      end
    end

    attributes
  end
end
