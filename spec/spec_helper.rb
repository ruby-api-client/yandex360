# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
require "simplecov-lcov"
require "Yandex360"
require "webmock/rspec"
require "vcr"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

SimpleCov.start do
  add_filter "spec/"
  add_group "Lib", "lib"
  minimum_coverage 80.0
end

ACCESS_TOKEN = ENV["YANDEX360_ACCESS_TOKEN"] || "SECRET_TOKEN"

RSpec.configure do |config|
  config.before(:each) do
    @yandex360 = Yandex360::Client.new(token: ACCESS_TOKEN)
  end

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

VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir = "spec/vcr"
  c.hook_into :webmock

  c.default_cassette_options = {
    decode_compressed_response: true,
    allow_unused_http_interactions: false
  }

  c.filter_sensitive_data("TOKEN") do |i|
    i.request["headers"]["Authorization"].first
  end

  c.configure_rspec_metadata!
end
