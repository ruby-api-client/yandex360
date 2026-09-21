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

    # OrganizationsService offers a list and nothing narrower, so this walks
    # it. The token usually reaches one organization, so it is a single
    # request in practice, but it is a search rather than a fetch.
    def info(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      list.auto_paginate.find {|organization| organization.id.to_s == org_id.to_s }
    end
  end
end
