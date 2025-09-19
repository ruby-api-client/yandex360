# frozen_string_literal: true

module Yandex360
  class AuditResource < Resource
    def list(org_id:, page: 1, per_page: 100, **params)
      validate_required_params({org_id: org_id}, [:org_id])
      query_params = {page: page, perPage: per_page}.merge(params)
      resp = get("/audit/v1/org/#{org_id}/events", params: query_params)
      Collection.from_response(resp, key: "events", type: AuditEvent)
    end

    def export(org_id:, **params)
      validate_required_params({org_id: org_id}, [:org_id])
      Object.new post("/audit/v1/org/#{org_id}/events/export", body: params).body
    end
  end
end