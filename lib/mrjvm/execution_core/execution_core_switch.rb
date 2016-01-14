module ExecutionCoreSwitch
  def execute_table_switch(frame)
    MRjvm.debug('Executing table switch.')

    index = frame.stack[frame.sp].value
    byte_code = get_method_byte_code(frame)
    pc_offset = get_table_switch_padding_offset(frame)
    default_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    min_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    max_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    address_array = {}
    (min_value..max_value).each do |i|
      address_array[i] = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
      pc_offset += 4
    end
    frame.sp -= 1
    address_array[index].nil? ? default_value : address_array[index]
  end

  def get_table_switch_padding_offset(frame)
    4 - ((frame.pc) % 4)
  end

  def execute_table_lookup_switch(frame)
    MRjvm.debug('Executing table lookup switch.')

    index = frame.stack[frame.sp].value
    byte_code = get_method_byte_code(frame)
    pc_offset = get_table_switch_padding_offset(frame)
    default_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    count = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
    pc_offset += 4
    address_array = {}
    (0...count).each do |i|
      index_value = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
      pc_offset += 4
      address_array[index_value] = byte_code[frame.pc + pc_offset, 4].join.to_i(16)
      pc_offset += 4
    end
    frame.sp -= 1
    address_array[index].nil? ? default_value : address_array[index]
    end
end