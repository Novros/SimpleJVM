module ClassFile
  class NoSuchFieldError < StandardError
  end

  class JavaClass
    attr_accessor :magic, :minor_version, :major_version,
                  :constant_pool_count, :constant_pool, :access_flags,
                  :this_class, :super_class, :interfaces_count, :interfaces,
                  :fields_count, :fields, :methods_count, :methods,
                  :attributes_count, :attributes, :class_heap, :static_variables

    def initialize
      @constant_pool = []
      @interfaces = []
      @fields = []
      @methods = []
      @attributes = []
      @static_variables = []
    end

    # if recursive parameter is true find constant recursive in child constants
    def get_from_constant_pool(index, recursive = false)
      constant = @constant_pool[index-1]

      if constant.has_key?(:name_index) && recursive
        @constant_pool[constant[:name_index]-1][:bytes]
      else
        constant[:bytes]
      end
    end

    def this_class_str
      get_from_constant_pool(@constant_pool[this_class-1][:name_index])
    end

    def super_class_str
      if super_class > 0
        get_from_constant_pool(@constant_pool[super_class-1][:name_index])
      end
    end

    def get_super_class
      if super_class > 0
        class_heap.get_class(super_class_str)
      end
    end

    def get_method_index(method_name, method_descriptor, static)
      methods.each_with_index do |method, index|
        static_method = (method[:access_flags].to_i(16) & AccessFlagsReader::ACC_STATIC != 0)
        if get_from_constant_pool(method[:name_index]) == method_name &&
            get_from_constant_pool(method[:descriptor_index]) == method_descriptor &&
            static_method == static
          return index
        end
      end
      -1
    end

    def get_method(method_name, method_descriptor)
      methods[get_method_index(method_name, method_descriptor, false)]
    end

    def is_overriding_method(method_name, method_descriptor)
      # This class must be subclass of A
      if super_class_str == 'java/lang/Object'
        false
      else
        super_class = get_super_class
        super_class_method_index = super_class.get_method_index(method_name, method_descriptor, false)
        return false if super_class_method_index == -1
        super_class_method = super_class.methods[super_class_method_index]
        access_flags = super_class_method[:access_flags].to_i(16)
        if (access_flags & AccessFlagsReader::ACC_PUBLIC) != 0 ||
            (access_flags & AccessFlagsReader::ACC_PROTECTED) != 0 ||
            (access_flags & AccessFlagsReader::ACC_PRIVATE) == 0 # TODO Add and must be in same runtime package.
          return true
          # elsif m1 overrides a method m3, m3 distinct from m1, m3 distinct from m2, such that m3 overrides m2
          #  return true
        else
          return false
        end
      end
    end

    def create_object(index, object_heap)
      constant = constant_pool[index]

      case constant[:tag]
        when TagReader::CONSTANT_METHODREF
          constant = constant_pool[constant[:class_index]-1]
        when TagReader::CONSTANT_STRING
          constant = constant_pool[constant[:string_index]-1]
          # create string
          return object_heap.create_string_object(constant[:bytes], class_heap)
      end

      # get class name
      name = get_from_constant_pool(constant[:name_index])
      java_class = class_heap.get_class(name)
      # create object
      object_heap.create_object(java_class)
    end

    def get_static_field(index, object_heap)
      unless static_variables[index].nil?
        return static_variables[index]
      end
      field_ref = constant_pool[index]
      raise StandardError, 'It is not field ref.' unless field_ref[:tag] == TagReader::CONSTANT_FIELDREF
      field_in_class_name = constant_pool[constant_pool[field_ref[:class_index] - 1][:name_index] - 1][:bytes]

      name_and_type = constant_pool[field_ref[:name_and_type_index] - 1]
      name = constant_pool[name_and_type[:name_index] - 1][:bytes]
      descriptor = constant_pool[name_and_type[:descriptor_index] - 1][:bytes]

      field_in_class = class_heap.get_class(field_in_class_name)
      static_variables[index] = field_in_class.get_static_value(name, descriptor, object_heap)
      static_variables[index]
    end

    def get_static_value(name, descriptor, object_heap)
      constant_pool.each do |constant|
        if constant[:tag] == TagReader::CONSTANT_NAME_AND_TYPE
          this_name = constant_pool[constant[:name_index] - 1][:bytes]
          this_descriptor = constant_pool[constant[:descriptor_index] - 1][:bytes]
          if name == this_name && descriptor == this_descriptor
            class_name = this_descriptor[1, this_descriptor.size-2]
            if this_descriptor == 'Z' # Boolean
              return Heap::StackVariable.new(Heap::VARIABLE_INT, 0)
            else
              return object_heap.create_object(class_heap.get_class(class_name))
            end
          end
        end
      end
      # TODO lookup in interfaces
      if super_class_str == 'java/lang/Object'
        raise NoSuchFieldError
      else
        get_super_class.get_static_value(name, descriptor, object_heap)
      end
    end

    def put_static_field(index, value, object_heap)
      puts self
      if static_variables[index].nil?
        static_variables[index] = value
        return
      end
      raise StandardError
      # field_ref = constant_pool[index]
      # raise StandardError, 'It is not field ref.' unless field_ref[:tag] == TagReader::CONSTANT_FIELDREF
      # field_in_class_name = constant_pool[constant_pool[field_ref[:class_index] - 1][:name_index] - 1][:bytes]
      #
      # name_and_type = constant_pool[field_ref[:name_and_type_index] - 1]
      # name = constant_pool[name_and_type[:name_index] - 1][:bytes]
      # descriptor = constant_pool[name_and_type[:descriptor_index] - 1][:bytes]
      #
      # field_in_class = class_heap.get_class(field_in_class_name)
      # static_variables[index] = field_in_class.get_static_value(name, descriptor, object_heap)
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

      string << "[DEBUG][METHODS] methods(#{@methods.size}): \n"
      @methods.each do |method|
        string << "[DEBUG][METHOD] \t#{method}\n"
      end

      string << "[DEBUG][STATIC] values(#{@static_variables.size}): \n"
      @static_variables.each do |variable|
        string << "[DEBUG][STATIC] \t#{variable}"
      end
      string
    end
  end
end