require_relative 'code_attribute_reader'
require_relative 'constant_attribute_reader'
require_relative 'exception_attribute_reader'

class AttributeReaderError < StandardError
end

module AttributesReader
  ATTRIBUTE_CONSTANT = 'ConstantValue'
  ATTRIBUTE_CODE = 'Code'
  ATTRIBUTE_EXCEPTIONS = 'Exceptions'

  include CodeAttributeReader
  include ExceptionAttributeReader
  include ConstantAttributeReader

  def read_attributes(attributes_count = nil)
    attributes_count.nil? &&
      (attributes_count = load_bytes(2).to_i(16))

    attributes_count.times do
      attribute_name_index = load_bytes(2).to_i(16)
      attribute_name = @class_file.constant_pool[attribute_name_index-1][:bytes]

      case attribute_name
        when ATTRIBUTE_CODE
          read_code_attribute(attribute_name_index)
        when ATTRIBUTE_CONSTANT
          read_constant_attribute(attribute_name_index)
        when ATTRIBUTE_EXCEPTIONS
          read_exception_attribute(attribute_name_index)
        else
          fail AttributeReaderError, 'non existing attribute name; index: ' +
                                     attribute_name_index.to_s + '; name: ' + attribute_name
      end
      break
    end
  end
end