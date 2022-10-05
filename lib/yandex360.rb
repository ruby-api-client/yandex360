# frozen_string_literal: true

require "addressable/uri"
require "faraday"
require "faraday_middleware"
require "yandex360/version"

module Yadisk
  autoload :Client, "yandex360/client"
end
