require 'fiddle'
require 'fiddle/struct'
require 'fiddle/import'
require_relative '../heap/object_heap'
require_relative 'file/file_manager'
require_relative 'modules/native_lib'
require_relative 'modules/native_run_types'
require_relative 'modules/native_run'
require_relative 'modules/native_file'
require_relative 'modules/native_string_builder'
require_relative 'modules/native_print'

module Native
  # This class run native methods from loaded shared libs.
  class NativeRunner
    attr_accessor :frame, :class_heap, :object_heap

    # File manager for file module
    @@file_manager = FileManager.new

    # Library loader
    include NativeLib

    # Native run method
    include NativeRunTypes
    include NativeRun

    # Fake native methods
    include NativePrint
    include NativeStringBuilder
    include NativeFile

    def run(method_signature, true_native)
      if true_native
        run_native(method_signature)
      else
        self.method(method_signature.to_sym).call
      end
    end

    def char_array_to_string(array_pointer)
      array = object_heap.get_object(array_pointer)
      string = ''
      array.variables.each do |char|
        string << char.value.chr
      end
      string
    end

    def file_manager
      @@file_manager
    end
  end
end
