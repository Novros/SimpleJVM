class ClassFile
  attr_accessor :magic, :minor_version, :major_version,
                :constant_pool_count, :constant_pool, :access_flags,
                :this_class, :super_class, :interfaces_count, :interfaces,
                :fields_count, :fields, :methods_count, :methods,
                :attributes_count, :attributes

  def initialize
    @constant_pool = []
    @interfaces = []
    @fields = []
    @methods = []
    @attributes = []
  end

  def to_s
    string = 'magic: ' + @magic + "\n"
    string += 'minor version: ' + @minor_version.to_s + "\n"
    string += 'major version: ' + @major_version.to_s + "\n"
    string += 'access_flags: ' +  @access_flags.to_s + "\n"
    string += 'this class (constant pool indexes): ' +  @this_class.to_s + "\n"
    string += 'super class (constant pool indexes): ' +  @super_class.to_s + "\n"
    string += 'constant pool count: ' + @constant_pool_count.to_s + "\n"
    string += 'constant pool: ' + "\n"
    @constant_pool.each do |constant|
      string += '  ' + constant.to_s + "\n"
    end

    string += 'interfaces (constant pool indexes): ' + interfaces.to_s + "\n"
    string += 'fields: ' + "\n"
    @fields.each do |field|
      string += '  ' + field.to_s + "\n"
    end

    string += 'methods: ' + "\n"
    @methods.each do |method|
      string += '  ' + method.to_s + "\n"
    end

    string
  end
end