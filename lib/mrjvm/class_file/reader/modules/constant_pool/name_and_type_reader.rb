require_relative 'tag_reader'

module NameAndTypeReader
  def read_name_and_type
    name_and_type = {}
    name_and_type[:tag] = TagReader::CONSTANT_NAME_AND_TYPE
    name_and_type[:name_index] = load_bytes(2).to_i(16)
    name_and_type[:descriptor_index] = load_bytes(2).to_i(16)
    name_and_type
  end
end
