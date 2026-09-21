# frozen_string_literal: true

module Yandex360
  class OrganizationsResource < Resource
    # Pages by token rather than page number, so there is no page argument.
    # page_size is capped at 100 by the API.
    def list(page_size: 10, page_token: nil)
      params = {pageSize: page_size}
      params[:pageToken] = page_token unless page_token.nil?

      resp = get("/directory/v1/org", params: params)
      Collection.from_response(resp, key: "organizations", type: Organization) do |token|
        list(page_size: page_size, page_token: token)
      end
    end

    def info(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      Organization.new get("/directory/v1/org/#{org_id}").body
    end
  end
end
