# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plan_out/version'

Gem::Specification.new do |spec|
  spec.name          = "f52-planout"
  spec.version       = PlanOut::VERSION
  spec.authors       = ["Ryan Kortmann"]
  spec.email         = ["ryan.kortmann@food52.com"]
  spec.summary       = %q{PlanOut is a framework and programming language for online field experimentation.}
  spec.description   = %q{PlanOut is a framework and programming language for online field experimentation. PlanOut was created to make it easy to run and iterate on sophisticated experiments, while satisfying the constraints of deployed Internet services with many users.}
  spec.homepage      = "https://github.com/food52/planout"
  spec.license       = "BSD"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "minitest", "~> 5.5"
  spec.add_development_dependency "rake", "~> 10.0"
end
