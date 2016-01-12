require_relative 'output_file'

class OpenFileError < StandardError
end

class OutputFileManager
  def initialize
    @map = {}
  end

  def open (object_id, filename)
    @map[object_id] = OutputFile.new(filename)
  end

  def write_line (object_id, line)
    file = @map[object_id]
    unless file.nil?
      file.write_line(line)
    else
      raise OpenFileError
    end
  end

  def write (object_id, text)
    file = @map[object_id]
    unless file.nil?
      file.write(text)
    else
      raise OpenFileError
    end
  end

  def close (object_id)
    file = @map[object_id]
    unless file.nil?
      file.close
    end
  end

end
