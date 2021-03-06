# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "sentry-reddit"
  gem.version       = File.new("VERSION", 'r').read.chomp
  gem.summary       = %q{Parses messages for reddit links then replies with information about the link}
  gem.license       = "MIT"
  gem.authors       = ["jRiddick"]
  gem.email         = "apersson.93@gmail.com"
  gem.homepage      = "https://rubygems.org/gems/sentry-reddit"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'

  gem.add_dependency "cinch", "~> 2.0"
  gem.add_dependency "redditkit", "~> 1.0"
  gem.add_dependency "twitter-text", "~> 1.13"
  gem.add_dependency "sentry-helper", "~> 0.1.0"
end
