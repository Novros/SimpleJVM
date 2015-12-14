module MagicReader
  def read_magic
    @read_position != 0 &&
      (fail ClassFileReaderError,
            'Error to get magic bytes; read position: ' +
              @read_position + '; expected position: 0')
    @class_file.magic = load_bytes(4)
  end
end