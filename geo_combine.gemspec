# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geo_combine/version'

Gem::Specification.new do |spec|
  spec.name          = "geo_combine"
  spec.version       = GeoCombine::VERSION
  spec.authors       = ["Jack Reed"]
  spec.email         = ["pjreed@stanford.edu"]
  spec.summary       = %q{A Ruby toolkit for managing geospatial metadata}
  spec.description   = %q{A Ruby toolkit for managing geospatial metadata}
  spec.homepage      = ""
  spec.license       = "Apache"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'rsolr'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'json-schema'
  spec.add_dependency 'sanitize'
  spec.add_dependency 'thor'
  spec.add_dependency 'faraday-net_http_persistent', '~> 2.0'
  spec.add_dependency 'git'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-html-matchers'
  spec.add_development_dependency 'rubocop', '~> 1.25'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.8'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock', '~> 3.14'
end
