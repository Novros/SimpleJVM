require_relative '../class_file/reader/class_file_reader'

reader = ClassFileReader.new("#{File.dirname(__FILE__)}/../../class_file_examples/KnapsackProblem.class")

#puts reader.input
reader.parse_content
puts reader.class_file
