# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in geo_combine.gemspec
gemspec

gem 'byebug', require: false
gem 'rdbg', require: false

# json 3 dropped the quirks_mode keyword that json-schema still passes to
# JSON.parse, which fails every schema validation. Constrained here rather than
# in the gemspec so the limit doesn't propagate to applications using the gem.
gem 'json', '< 3'
