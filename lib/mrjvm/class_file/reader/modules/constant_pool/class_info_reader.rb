require_relative 'tag_reader'

module ClassInfoReader
  def read_class_info
    class_info = {}
    class_info[:tag] = TagReader::CONSTANT_CLASS
    class_info[:name_index] = load_bytes(2).to_i(16)
    class_info
  end
end
