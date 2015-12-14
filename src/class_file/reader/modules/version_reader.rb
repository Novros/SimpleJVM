module VersionReader
  def read_versions
    @class_file.minor_version = load_bytes(2).to_i(16)
    @class_file.major_version = load_bytes(2).to_i(16)
  end
end