class OutputFile
  attr_reader :filename

  def initialize(filename)
    @filename = filename
    @file = File.open(@filename, 'w')
  end

  def write_line(line)
    @file.write(line + "\n")
  end

  def write(text)
    @file.write(text)
  end

  def close
    @file.close
  end
end
