module ClassFile
  class JavaClass
    attr_accessor :magic, :minor_version, :major_version,
                  :constant_pool_count, :constant_pool, :access_flags,
                  :this_class, :super_class, :interfaces_count, :interfaces,
                  :fields_count, :fields, :methods_count, :methods,
                  :attributes_count, :attributes, :class_heap

    def initialize
      @constant_pool = []
      @interfaces = []
      @fields = []
      @methods = []
      @attributes = []
    end

    # !!!! TODO Maybe create some internal representation???

    def get_string_from_constant_pool(index)
      @constant_pool[index-1][:bytes]
    end

    def this_class_str
      get_string_from_constant_pool(@constant_pool[this_class-1][:name_index])
    end

    def super_class_str
      get_string_from_constant_pool(@constant_pool[super_class-1][:name_index])
    end

    def get_method_index(method_name)
      methods.each_with_index do |method, index|
        return index if get_string_from_constant_pool(method[:name_index]) == method_name
      end
      -1
    end

    def to_s
      string = 'magic: ' << @magic << "\n"
      string << 'minor version: ' << @minor_version.to_s << "\n"
      string << 'major version: ' << @major_version.to_s << "\n"
      string << 'access_flags: ' << @access_flags.to_s << "\n"
      string << 'this class (constant pool indexes): ' << @this_class.to_s << "\n"
      string << 'super class (constant pool indexes): ' << @super_class.to_s << "\n"
      string << 'constant pool count: ' << @constant_pool_count.to_s << "\n"
      string << 'constant pool: ' << "\n"
      @constant_pool.each do |constant|
        string << '  ' << constant.to_s << "\n"
      end

      string << 'interfaces (constant pool indexes): ' << interfaces.to_s << "\n"
      string << 'fields: ' << "\n"
      @fields.each do |field|
        string << '  ' << field.to_s << "\n"
      end

      string << "methods: \n"
      @methods.each do |method|
        string << "  #{method}\n"
      end
      string
    end
  end
end