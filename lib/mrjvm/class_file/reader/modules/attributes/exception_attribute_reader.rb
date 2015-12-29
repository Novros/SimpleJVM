module ExceptionAttributeReader
  def read_exception_attribute(name_index)
    attribute = {}
    attribute[:attribute_name_index] = name_index
    attribute[:attribute_length] = load_bytes(4).to_i(16)
    attribute[:number_of_exceptions] = load_bytes(2).to_i(16)

    attribute[:exception_index_table] = []
    attribute[:number_of_exceptions].times do
      attribute[:exception_index_table] << load_bytes(2).to_i(16)
    end
  end
end
