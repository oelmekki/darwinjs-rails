# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'darwinjs/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "darwinjs-rails"
  spec.version       = Darwinjs::Rails::VERSION
  spec.authors       = ["Olivier El Mekki"]
  spec.email         = ["olivier@el-mekki.com"]
  spec.description   = %q{Javascript framework with progressive enhancement in mind.}
  spec.summary       = %q{Darwin lets create complex javascript interfaces that do not expect they own the application and that degrade gracefully when an error occurs}
  spec.homepage      = "https://github.com/oelmekki/darwinjs-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'railties', '~> 4.2'
  spec.add_dependency 'coffee-rails', '~> 4.1'
  spec.add_dependency 'jquery-rails', '~> 4.0'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake"
end
