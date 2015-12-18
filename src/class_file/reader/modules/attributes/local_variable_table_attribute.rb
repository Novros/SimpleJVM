module LocalVariableTableAttribute
  def read_local_variable_table_attribute(name_index)
    attribute = {}
    attribute[:attribute_name_index] = name_index
    attribute[:attribute_length] = load_bytes(4).to_i(16)
    attribute[:local_variable_table_length] = load_bytes(2).to_i(16)

    attribute[:local_variable_table] = []
    attribute[:local_variable_table_length].times do
      table_item = {
        :start_pc => load_bytes(2).to_i(16),
        :length => load_bytes(2).to_i(16),
        :name_index => load_bytes(2).to_i(16),
        :descriptor_index => load_bytes(2).to_i(16),
        :index => load_bytes(2).to_i(16)
      }

      attribute[:local_variable_table] << table_item
    end
    attribute
  end
end
