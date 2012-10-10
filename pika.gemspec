# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pika/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Davide Targa"]
  gem.email         = ["davide.targa@gmail.com"]
  gem.description   = %q{Download files from xspf playlists}
  gem.summary       = %q{Download files from xspf playlists}
  gem.homepage      = "https://github.com/davide-targa/pika"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pika"
  gem.require_paths = ["lib"]
  gem.version       = Pika::VERSION

  gem.add_dependency 'xspf'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'colored'
  gem.add_dependency 'ruby-progressbar'
  gem.add_dependency 'terminal-table'
  gem.add_runtime_dependency "thor"
end
