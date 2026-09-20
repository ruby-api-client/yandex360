# frozen_string_literal: true

require "faraday"
begin
  # Extracted from faraday core in 2.0. Bundled there in 1.x.
  require "faraday/retry"
rescue LoadError
  nil
end

# Base classes first: types subclass Object, resources subclass Resource.
require "yandex360/version"
require "yandex360/error"
require "yandex360/object"
require "yandex360/collection"
require "yandex360/param_builder"
require "yandex360/resource"
require "yandex360/objects/types"
require "yandex360/client"

# Resources are loaded by directory rather than listed. The list they replace
# had to be edited by hand for every new resource, and forgetting an entry
# raises NameError for the caller at runtime, which the suite only catches if
# some spec happens to touch that constant.
Dir[File.join(__dir__, "yandex360", "resources", "*.rb")].sort.each do |resource|
  require resource
end
