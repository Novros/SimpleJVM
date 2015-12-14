##
# Read reference to constant pool table for this class
# and super class (super class can be zero)
module ThisSuperReader
  def read_this_class
    @class_file.this_class = load_bytes(2).to_i(16)
  end

  def read_super_class
    @class_file.super_class = load_bytes(2).to_i(16)
  end
end