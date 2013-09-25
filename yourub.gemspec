# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yourub/version'

Gem::Specification.new do |spec|
  spec.name          = "yourub"
  spec.version       = Yourub::VERSION
  spec.authors       = ["Davide Prati"]
  spec.email         = ["lastexxit@gmail.com "]
  spec.description   = %q{Youtube Standard feed API parser}
  spec.summary       = %q{Retrieve videos metatags}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_dependency "thor" , '~> 0.18'
end
