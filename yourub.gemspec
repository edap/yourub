# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yourub/version'

Gem::Specification.new do |spec|
  spec.name          = "yourub"
  spec.version       = Yourub::VERSION
  spec.authors       = ["Davide Prati"]
  spec.email         = ["lastexxit@gmail.com "]
  spec.description   = %q{Youtube API v3 parser}
  spec.summary       = %q{Yourub is a gem that search videos on youtebe using the YouTube API v3}
  spec.homepage      = "https://github.com/edap/yourub"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'google-api-client', '~> 0.7', '< 0.9'
  spec.add_development_dependency "bundler", "~> 1.3"

end
