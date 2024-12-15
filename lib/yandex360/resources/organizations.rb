# frozen_string_literal: true

module Yandex360
  class OrganizationResource < Resource
    def list
      Organization.new get("directory/v1/org").body
    end
  end
end
