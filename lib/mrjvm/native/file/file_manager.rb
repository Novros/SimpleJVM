require_relative 'input_file_manager'
require_relative 'output_file_manager'

class FileManager
  def initialize
    @input_manager = InputFileManager.new
    @output_manager = OutputFileManager.new
  end

  def open (object_id, filename, type)
    if type == 'r'
      @input_manager.open(object_id, filename)
    elsif type == 'w'
      @output_manager.open(object_id, filename)
    else
      raise StandardError, 'Bad type for FileManager:open.'
    end
  end

  def write(object_id, text)
    @output_manager.write(object_id, text)
  end

  def write_line(object_id, text)
    @output_manager.write_line(object_id, text)
  end

  def read_line(object_id)
    @input_manager.read_line(object_id)
  end

  def read_file(object_id)
    @input_manager.read_file(object_id)
  end

  def close(object_id, type)
    if type == 'r'
      @input_manager.close(object_id)
    elsif type == 'w'
      @output_manager.close(object_id)
    else
      raise StandardError, 'Bad type for FileManager:close.'
    end
  end
end