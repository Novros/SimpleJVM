module SignatureAttributeReader
  def read_signature_attribute(name_index)
    attribute = {}
    attribute[:attribute_name_index] = name_index
    attribute[:attribute_length] = load_bytes(4).to_i(16)
    attribute[:signature_index] = load_bytes(2).to_i(16)
    attribute
  end
end
