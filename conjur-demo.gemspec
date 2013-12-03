# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'conjur/demo/version'

Gem::Specification.new do |spec|
  spec.name          = "conjur-demo"
  spec.version       = Conjur::Demo::VERSION
  spec.authors       = ["Derek Kastner"]
  spec.email         = ["dkastner@gmail.com"]
  spec.description   = %q{A demo of the Conjur API}
  spec.summary       = %q{This demo of the Conjur API creates sample permissions
                          for doctors, nurses, and patients}
  spec.homepage      = "http://developer.conjur.net"
  spec.license       = "Proprietary"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "conjur-api", "~> 4.3.0"
  spec.add_dependency "conjur-cli", "~> 4.3.0"

  spec.add_development_dependency "aruba"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "rake"
end
