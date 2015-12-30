module AccessFlagsReader
  ACC_PUBLIC = 0x0001
  ACC_PRIVET = 0x0002
  ACC_PROTECTED = 0x0004
  ACC_STATIC = 0x0008
  ACC_FINAL = 0x0010
  ACC_SUPER = 0x0020
  ACC_NATIVE = 0x0100
  ACC_INTERFACE = 0x0200
  ACC_ABSTRACT = 0x0400
  ACC_STRICT = 0x0800
  ACC_SYNTHETIC = 0x1000
  ACC_ANNOTATION = 0x2000
  ACC_ENUM = 0x4000

  def read_access_flags
    access_flags = load_bytes(2)
    @class_file.access_flags = access_flags
  end

  def self.public?(flag)
    (flag & ACC_PUBLIC) > 0
  end

  def self.super?(flag)
    (flag & ACC_SUPER) > 0
  end

  def self.final?(flag)
    (flag & ACC_FINAL) > 0
  end

  def self.interface?(flag)
    (flag & ACC_INTERFACE) > 0
  end

  def self.abstract?(flag)
    (flag & ACC_ABSTRACT) > 0
  end

  def self.synthetic?(flag)
    (flag & ACC_SYNTHETIC) > 0
  end

  def self.annotation(flag)
    (flag & ACC_ANNOTATION) > 0
  end

  def self.enum?(flag)
    (flag & ACC_ENUM) > 0
  end
end
