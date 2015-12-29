module SourceFileAttributeReader
  def read_source_file_attribute(name_index)
    attribute = {}
    attribute[:attribute_name_index] = name_index
    attribute[:attribute_length] = load_bytes(4).to_i(16)
    attribute[:sourcefile_index] = load_bytes(2).to_i(16)
    attribute
  end
end