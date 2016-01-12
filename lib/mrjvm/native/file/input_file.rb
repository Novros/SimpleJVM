class InputFile
  attr_reader :filename

  def initialize(filename)
    @filename = filename
    @file = File.open(@filename, 'r')
  end

  def read_line
    line = @file.gets
    if line.nil?
      nil
    else
      line.chomp
    end
  end

  def read_file
    @file.read
  end

  def close
    @file.close
  end
end
