# frozen_string_literal: true

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start 'rails' do
  add_filter 'lib/tasks/geo_combine.rake'
  add_filter 'lib/geo_combine/version.rb'
  add_filter 'lib/geo_combine/railtie.rb'
  minimum_coverage 95 # When updating this value, update the README badge value
end

require 'geo_combine'
require 'fixtures/xml_docs'
require 'fixtures/json_docs'
require 'helpers'
require 'rspec-html-matchers'
require 'byebug'

# Setup webmock for specific tests
require 'webmock/rspec'
WebMock.allow_net_connect!

# include the spec support files
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.include Helpers
  config.include RSpecHtmlMatchers
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
