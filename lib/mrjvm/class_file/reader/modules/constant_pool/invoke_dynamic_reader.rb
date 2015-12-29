require_relative 'tag_reader'

module InvokeDynamicReader
  def read_invoke_dynamic
    invoke_dynamic = {}
    invoke_dynamic[:tag] = TagReader::CONSTANT_INVOKE_DYNAMIC
    invoke_dynamic[:bootstrap_method_attr_index] = load_bytes(2).to_i(16)
    invoke_dynamic[:name_and_type_index] = load_bytes(2).to_i(16)
    invoke_dynamic
  end
end
