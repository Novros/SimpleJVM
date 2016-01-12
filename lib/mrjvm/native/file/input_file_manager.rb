require_relative 'input_file'

class InputFileManager
  def initialize
    @map = {}
  end

  def open (object_id, filename)
    @map[object_id] = InputFile.new(filename)
  end

  def read_line (object_id)
    file = @map[object_id]
    unless file.nil?
      file.read_line
    else
      nil
    end
  end

  def read_file (object_id)
    file = @map[object_id]
    unless file.nil?
      file.read_file
    else
      nil
    end
  end

  def close (object_id)
    file = @map[object_id]
    unless file.nil?
      file.close
    end
  end

end
