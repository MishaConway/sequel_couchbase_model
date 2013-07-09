# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sequel_couchbase_model/version'

Gem::Specification.new do |spec|
  spec.name          = "sequel_couchbase_model"
  spec.version       = SequelCouchbaseModel::VERSION
  spec.authors       = ["Misha Conway"]
  spec.email         = ["misha.conway@machinima.com"]
  spec.description   = %q{Integrates sequel validations and sequel hooks into couchbase model.}
  spec.summary       = %q{ntegrates sequel validations and sequel hooks into couchbase model.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'sequel'
  spec.add_development_dependency 'couchbase-model'
end
