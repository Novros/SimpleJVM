require_relative 'attributes/attributes_reader'

module FieldsReader
  include AttributesReader

  def read_fields
    @class_file.fields_count = load_bytes(2).to_i(16)

    @class_file.fields_count.times do
      field = {}
      field[:access_flags] = load_bytes(2)
      field[:name_index] = load_bytes(2).to_i(16)
      field[:descriptor_index] = load_bytes(2).to_i(16)
      field[:attributes_count] = load_bytes(2).to_i(16)

      field[:attributes] = read_attributes(field[:attributes_count])
      @class_file.fields << field
    end
  end
end
