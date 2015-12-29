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
        opts.banner = 'Usage: mrjvm [path-to-file]'

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

  if ARGV[0].nil?
    puts 'Missing argument file.'
    exit(1)
  end

  file = ARGV[0]
  reader = ClassFileReader.new(file)
  reader.parse_content
  puts reader.class_file
end
