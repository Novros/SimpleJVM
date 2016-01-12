class InputFile
  attr_reader :filename

  def initialize(filename)
    @filename = filename
    @file = File.open(@filename, 'r')
  end

  def read_line
    @file.gets
  end

  def read_file
    @file.read
  end

  def close
    @file.close
  end
end
