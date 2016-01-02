require 'optparse'
require_relative 'version'
require_relative '../mrjvm'
require_relative 'class_file/reader/class_file_reader'

# Module for solving sudoku
module MRjvm

  # Interface for command line access
  class CLI
    def self.parse(args)
      options = {}
      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: mrjvm [options] [path-to-file]'

        opts.on_tail('-h', '--help', 'Print this help.') do
          puts opts
          exit
        end

        opts.on_tail('-v', '--version', 'Show version') do
          puts VERSION
          exit
        end

        opts.on('-d', '--debug', 'Run in debug. Print some info about run of vm.') do
          options[:debug] = true
        end

        opts.on('--frame-size', 'Size of stack for frame methods.') do
          options[:frame_size] = true
        end

        opts.on('--op-size', 'Size of operand stack.') do
          options[:op_size] = true
        end

        opts.on('-n', '--native', 'Path to used native libs.') do
          options[:native] = true
        end

        begin
          if ARGV.empty?
            puts opts.banner
            exit
          end
        rescue
          puts opts.banner
          exit(1)
        end
      end

      opt_parser.parse!(args)
      options
    end
  end

  options = CLI.parse(ARGV)

  if options[:debug].nil?
    DEBUG = false
  else
    DEBUG = true
  end

  jvm = MRjvm.new()
  options.each_with_index do |item, index|
    case item[0].to_s
      when 'frame_size'
        jvm.frame_size = ARGV[index].to_i
      when 'op_size'
        jvm.op_size = ARGV[index].to_i
      when 'native'
        jvm.native_lib_path = ARGV[index]
      else
    end
  end

  file = ARGV.last
  if file.nil? || !File.file?(file)
    puts 'Missing argument file or it is not file.'
    exit(1)
  end

  jvm.run(file)
end
