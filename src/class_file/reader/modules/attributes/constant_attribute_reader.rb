module ConstantAttributeReader
  def read_constant_attribute(name_index)
    attribute = {}
    attribute[:attribute_name_index] = name_index
    attribute[:attribute_length] = load_bytes(4).to_i(16) # expected is 2
    attribute[:constantvalue_index] = load_bytes(2).to_i(16)
    attribute
  end
end