# -*- encoding: utf-8 -*-
require File.expand_path('../lib/agile_check_in/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["phillc"]
  gem.email         = ["spyyderz@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "agile_check_in"
  gem.require_paths = ["lib"]
  gem.version       = AgileCheckIn::VERSION
end
