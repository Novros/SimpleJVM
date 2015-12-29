# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mrjvm/version'

Gem::Specification.new do |spec|
  spec.name          = "mrjvm"
  spec.version       = MRjvm::VERSION
  spec.authors       = ["Bc. Rostislav Novak, Bc. Matus Volosin"]
  spec.email         = ["novakro2@fit.cvut.cz, volosmat@fit.cvut.cz"]
  spec.summary       = "Semestral work for subject MI-RUN."
  spec.description   = "Our implementation of java virtual machine for subject MI-RUN."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

end
