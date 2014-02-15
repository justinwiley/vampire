# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vampire/version'

Gem::Specification.new do |gem|
  gem.name          = "vampire"
  gem.version       = Vampire::VERSION
  gem.authors       = ["Justin Wiley"]
  gem.email         = ["justin.wiley@gmail.com"]
  gem.description   = %q{A Ruby implementation of the visitor pattern}
  gem.summary       = %q{A Ruby implementation of the visitor pattern}
  gem.homepage      = "http://github.com/justinwiley/vampire"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "pry"

end
