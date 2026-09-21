# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Needed only by the Railtie spec, which boots a Rails application. Platforms
# without a system zoneinfo database, Windows among them, cannot do that
# without it, and Windows is in the CI matrix.
gem "tzinfo-data", platforms: %i[windows jruby]
