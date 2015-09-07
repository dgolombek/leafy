#-*- mode: ruby -*-

require File.expand_path( '../lib/leafy/rack/version', __FILE__ )

Gem::Specification.new do |s|
  s.name = 'leafy-rack'
  s.version = Leafy::Rack::VERSION
  s.author = 'christian meier'
  s.email = [ 'christian.meier@lookout.com' ]

  s.platform = 'java'
  s.license = 'MIT'
  s.summary = %q(rack middleware to expose leafy metrics/health data and more)
  s.homepage = 'https://github.com/lookout/leafy'
  s.description = %q(rack middleware to expose leafy metrics/health data as well a ping rack and a thread-dump rack)

  s.files = `git ls-files`.split($/)

  s.requirements << 'jar io.dropwizard.metrics:metrics-json, 3.1.0'
  s.requirements << 'jar io.dropwizard.metrics:metrics-jvm, 3.1.0'

  s.add_runtime_dependency 'jar-dependencies', '~> 0.1'
  s.add_runtime_dependency 'leafy-metrics', "~> #{Leafy::Rack::VERSION}"
  s.add_runtime_dependency 'leafy-health',  "~> #{Leafy::Rack::VERSION}"
  s.add_runtime_dependency 'leafy-logger', "~> #{Leafy::Rack::VERSION}"
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'yard', '~> 0.8.7'
  s.add_development_dependency 'rake', '~> 10.2'
end

# vim: syntax=Ruby
