# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mancora/version'

Gem::Specification.new do |spec|
  spec.name          = "mancora"
  spec.version       = Mancora::VERSION
  spec.authors       = ["cbron"]
  spec.email         = ["x@x.com"]
  spec.description   = %q{Automate queries over regular intervals for statistics}
  spec.summary       = %q{Easily save query counts on regular intervals into a single table to use for statistics.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end