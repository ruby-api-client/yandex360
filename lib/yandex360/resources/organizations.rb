# frozen_string_literal: true

module Yandex360
  class OrganizationsResource < Resource
    def list
      resp = get("/directory/v1/org")
      Collection.from_response(resp, key: "organizations", type: Organization)
    end

    def info(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      Organization.new get("/directory/v1/org/#{org_id}").body
    end
  end
end