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
  # Ship what consumers need and nothing else. `git ls-files` minus spec/ also
  # packaged .github/, .rubocop.yml, Gemfile.lock and the Rakefile.
  s.files         = Dir["lib/**/*.rb"] + %w[README.md README.ru.md LICENSE CHANGELOG.md]
  s.executables   = []
  s.require_paths = ["lib"]
  s.homepage      = "https://github.com/ruby-api-client/yandex360"
  s.license       = "MIT"

  # Matches the CI matrix. 3.1 and 3.2 are both past end of life, and faraday 2
  # already requires 3.0, so ">= 2.6" was never true. RubyGems keeps serving
  # older releases to older Rubies, so nobody's existing install breaks.
  s.required_ruby_version = ">= 3.3"

  s.metadata["rubygems_mfa_required"] = "true"

  # faraday 1.x cannot work here: its authorization middleware requires
  # base64, which stopped being a default gem in Ruby 3.4, and faraday 1
  # predates that change and never declared it. On the Rubies this gem
  # supports, building a client raises LoadError.
  s.add_dependency "faraday", "~> 2.0"
  # Retry middleware, split out of faraday core in 2.0.
  s.add_dependency "faraday-retry", "~> 2.0"

  s.add_development_dependency "fiddle", "~> 1.0"
  s.add_development_dependency "logger", "~> 1.4"

  s.add_development_dependency "bundler"
  s.add_development_dependency "bundler-audit", "~> 0.9"
  s.add_development_dependency "rake", "~> 13.3.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rubocop", "~> 1.60"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "simplecov-lcov", "~> 0.9.0"
end
