require_relative '../class_file'
require_relative 'modules/magic_reader'
require_relative 'modules/version_reader'
require_relative 'modules/constant_pool/constant_pool_reader'
require_relative 'modules/access_flags_reader'
require_relative 'modules/this_super_reader'
require_relative 'modules/interfaces_reader'
require_relative 'modules/fields_reader'
require_relative 'modules/method_reader'
require_relative 'modules/attributes/attributes_reader'

class ClassFileReaderError < StandardError
end

##
# Load and parse content of Java binary class file
# For more information about Java class file format see
# https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html
class ClassFileReader
  attr_accessor :class_file, :input
  include MagicReader
  include ConstantPoolReader
  include VersionReader
  include AccessFlagsReader
  include ThisSuperReader
  include InterfacesReader
  include FieldsReader
  include MethodReader
  include AttributesReader

  def initialize(file_path)
    @input = []
    @read_position = 0
    read_file_content(file_path)
    @class_file = ClassFile::ClassFile.new
  end

  # Start parsing content
  def parse_content
    read_magic
    read_versions
    read_constant_pool
    read_access_flags
    read_this_class
    read_super_class
    read_interfaces
    read_fields
    read_methods
    read_attributes
  end

  # Load count bytes from input array and move read position
  def load_bytes(count)
    result = ''
    count.times do
     result += @input[@read_position]
      @read_position += 1
    end
    result
  end

  # Get all bytes from file and store in array
  def read_file_content(file_path)
    File.open(file_path, 'r') do |io|
      io.read.each_byte.map do |byte|
        @input << byte.to_s(16).rjust(2,'0')
      end
    end
  end
end
