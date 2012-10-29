# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gruff_client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ryutaro MIZOKAMI"]
  gem.email         = ["suzunatsu@yahoo.com"]
  gem.description   = %q{gruff server's client}
  gem.summary       = %q{use for post to gruff server.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "gruff_client"
  gem.require_paths = ["lib"]
  gem.version       = GruffClient::VERSION

  gem.add_dependency 'hashie'
end
