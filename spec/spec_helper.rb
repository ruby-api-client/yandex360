# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
require "simplecov-lcov"

require "yandex360"

# Load support files
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

SimpleCov.start do
  add_filter "spec/"
  add_group "Lib", "lib"
  minimum_coverage 80.0
end

RSpec.configure do |config|
  config.include HttpStubs

  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
