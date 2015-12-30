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

    def get_super_class
      class_heap.get_class(super_class_str)
    end

    def get_method_index(method_name)
      methods.each_with_index do |method, index|
        return index if get_string_from_constant_pool(method[:name_index]) == method_name
      end
      -1
    end

    def create_object(index, object_heap)
      # TODO Checking if is constant CONSTANT_CLASS
      constant = constant_pool[index]
      constant = constant_pool[constant[:class_index]-1]
      name = get_string_from_constant_pool(constant[:name_index])
      java_class = class_heap.get_class(name)
      object_heap.create_object(java_class)
    end

    def to_s
      string = '[CLASS]' << "\n"
      string << '[DEBUG] magic: ' << @magic << "\n"
      string << '[DEBUG] minor version: ' << @minor_version.to_s << "\n"
      string << '[DEBUG] major version: ' << @major_version.to_s << "\n"
      string << '[DEBUG] access_flags: ' << @access_flags.to_s << "\n"
      string << '[DEBUG] this class (constant pool indexes): ' << @this_class.to_s << "\n"
      string << '[DEBUG] super class (constant pool indexes): ' << @super_class.to_s << "\n"
      string << '[DEBUG] constant pool count: ' << @constant_pool_count.to_s << "\n"
      string << '[DEBUG] constant pool: ' << "\n"
      @constant_pool.each do |constant|
        string << "[DEBUG][CONSTANT] \t#{constant}\n"
      end

      string << '[DEBUG][INTERFACES] interfaces (constant pool indexes): ' << interfaces.to_s << "\n"
      string << '[DEBUG][FIELDS] fields: ' << "\n"
      @fields.each do |field|
        string << "[DEBUG][FIELD] \t#{field}\n"
      end

      string << "[DEBUG][METHODS] methods: \n"
      @methods.each do |method|
        string << "[DEBUG][METHOD] \t#{method}\n"
      end
      string
    end
  end
end