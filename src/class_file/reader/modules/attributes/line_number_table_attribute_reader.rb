module LineNumberTableAttributeReader
  def read_line_number_table_attribute(name_index)
    attribute = {}
    attribute[:attribute_name_index] = name_index
    attribute[:attribute_length] = load_bytes(4).to_i(16)
    attribute[:line_number_table_length] = load_bytes(2).to_i(16)

    attribute[:line_number_table] = []
    attribute[:line_number_table_length].times do
      table_item = {
        :start_pc => load_bytes(2).to_i(16),
        :line_number => load_bytes(2).to_i(16)
      }

      attribute[:line_number_table] << table_item
    end
    attribute
  end
end
