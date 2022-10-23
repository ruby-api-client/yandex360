# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "yandex360/version"

Gem::Specification.new do |s|
  s.name          = "yandex360"
  s.version       = Yandex360::VERSION
  s.summary       = "Yandex 360 API client"
  s.description   = "Yandex 360 API wrapper written in Ruby"
  s.authors       = ["Ilya Brin"]
  s.email         = "ilya@codeplay.ru"
  s.files         = `git ls-files`.split($RS).reject {|fn| fn.start_with? "spec" }
  s.executables   = s.files.grep(%r{^bin/}) {|f| File.basename(f) }
  s.require_paths = ["lib"]
  s.homepage      = "https://github.com/ruby-api-client/yandex360"
  s.license       = "MIT"

  s.required_ruby_version = ">= 2.6"

  s.metadata["rubygems_mfa_required"] = "true"

  s.add_dependency "faraday", "~> 1.7"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake", "~> 12.3.3"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "simplecov-lcov", "~> 0.7.0"
  s.add_development_dependency "vcr", "~> 6.1"
  s.add_development_dependency "webmock", "~> 3.18", ">= 3.18.1"
end
