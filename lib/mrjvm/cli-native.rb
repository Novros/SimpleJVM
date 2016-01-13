require 'optparse'
require_relative 'version'
require_relative '../mrjvm-native'
require_relative 'class_file/reader/class_file_reader'

module MRjvm

  # Interface for command line access
  class CLI
    def self.parse(args)
      options = {}
      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: mrjvm-native [options] [path-to-file-class-file]'

        opts.on_tail('-h', '--help', 'Print this help.') do
          puts opts
          exit
        end

        opts.on_tail('-v', '--version', 'Show version') do
          puts VERSION
          exit
        end

        opts.on('-d', '--debug', 'Run in debug. Print some info about run of native creator.') do
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
  arg_index = 0

  if options[:debug].nil?
    DEBUG = false
  else
    DEBUG = true
  end

  file = ARGV[arg_index]
  if file.nil? || !File.file?(file)
    puts 'Missing argument file or it is not file.'
    exit(1)
  end

  native = MrjvmNative.new(file)
  native.run()
end
