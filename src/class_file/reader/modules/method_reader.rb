require_relative 'attributes/attributes_reader'

module MethodReader
  include AttributesReader

  def read_methods
    @class_file.methods_count = load_bytes(2).to_i(16)

    @class_file.methods_count.times do
      method = {}
      method[:access_flags] = load_bytes(2)
      method[:name_index] = load_bytes(2).to_i(16)
      method[:descriptor_index] = load_bytes(2).to_i(16)
      method[:attributes_count] = load_bytes(2).to_i(16)

      method[:attributes] = read_attributes(method[:attributes_count])

      @class_file.methods << method
    end
  end
end