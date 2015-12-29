module CodeAttributeReader
  def read_code_attribute(name_index)
    attribute = {}
    attribute[:attribute_name_index] = name_index
    attribute[:attribute_length] = load_bytes(4).to_i(16)
    attribute[:max_stack] = load_bytes(2).to_i(16)
    attribute[:max_locals] = load_bytes(2).to_i(16)

    attribute[:code_length] = load_bytes(4).to_i(16)
    attribute[:code] = []
    # read bytecode
    attribute[:code_length].times do
      attribute[:code] << load_bytes(1)
    end

    attribute[:exception_table_length] = load_bytes(2).to_i(16)
    attribute[:exception_table] = []
    # read exceptions
    attribute[:exception_table_length].times do
      exception = {
        :start_pc => load_bytes(2).to_i(16), # index to code array
        :end_pc => load_bytes(2).to_i(16), # index to code array
        :handler_pc => load_bytes(2).to_i(16), # index to code array
        :catch_type => load_bytes(2).to_i(16) # index to constant pool
      }

      attribute[:exception_table] << exception
    end

    attribute[:attributes_count] = load_bytes(2).to_i(16)
    # read attributes
    attribute[:attributes] = read_attributes(attribute[:attributes_count])
  end
end
