module StackMapTableAttributeReader
  def read_stack_map_table_attribute(name_index)
    attribute = {}
    attribute[:attribute_name_index] = name_index
    attribute[:attribute_length] = load_bytes(4).to_i(16)
    attribute[:number_of_entries] = load_bytes(2).to_i(16)

    attribute[:entries] = []
    attribute[:number_of_entries].times do
      attribute[:entries] << read_stack_map_frame
    end
    attribute
  end
  
  def read_stack_map_frame
    frame = {}
    frame[:frame_type] = load_bytes(1).to_i(16)
    case
      when frame[:frame_type] >= 64 && frame[:frame_type] <= 127
        frame[:stack] = [read_verification_type_info]
      when frame[:frame_type] == 247
        frame[:offset_delta] = load_bytes(2).to_i(16)
        frame[:stack] = [read_verification_type_info]
      when frame[:frame_type] >= 248 && frame[:frame_type] <= 250
        frame[:offset_delta] = load_bytes(2).to_i(16)
      when frame[:frame_type] == 251
        frame[:offset_delta] = load_bytes(2).to_i(16)
      when frame[:frame_type] >= 252 && frame[:frame_type] <= 254
        frame[:offset_delta] = load_bytes(2).to_i(16)
        number_of_locals = frame[:frame_type] - 251
        frame[:locals] = []
        number_of_locals.times { frame[:locals] << read_verification_type_info }
      when frame[:frame_type] == 255
        # Full frame
        frame[:offset_delta] = load_bytes(2).to_i(16)
        frame[:number_of_locals] = load_bytes(2).to_i(16)

        frame[:locals] = []
        frame[:number_of_locals].times do
          frame[:locals] << read_verification_type_info
        end

        frame[:number_of_stack_items] = load_bytes(2).to_i(16)
        frame[:stack] = []
        frame[:number_of_stack_items].times do
          frame[:stack] << read_verification_type_info
        end
      else
        return frame
    end

    frame
  end

  def read_verification_type_info
    type_info = {}
    type_info[:tag] = load_bytes(1).to_i(16)
    if type_info[:tag] == 7
      type_info[:cpool_index] = load_bytes(2).to_i(16)
    end

    if type_info[:tag] == 8
      type_info[:offset] = load_bytes(2).to_i(16)
    end

    type_info
  end
end
