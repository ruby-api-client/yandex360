# frozen_string_literal: true

module Yandex360
  class DnsResource < Resource
    include ParamBuilder

    def list(org_id:, domain:)
      validate_required_params({org_id: org_id, domain: domain}, [:org_id, :domain])
      resp = get("/directory/v1/org/#{org_id}/domains/#{domain}/dns")
      Collection.from_response(resp, key: "records", type: DnsRecord)
    end

    def create(org_id:, domain:, **params)
      validate_required_params({org_id: org_id, domain: domain}, [:org_id, :domain])
      dns_record = build_params({}, params)
      DnsRecord.new post("/directory/v1/org/#{org_id}/domains/#{domain}/dns", body: dns_record).body
    end

    def update(org_id:, domain:, record_id:, **params)
      validate_required_params({org_id: org_id, domain: domain, record_id: record_id}, [:org_id, :domain, :record_id])
      dns_record = build_params({}, params)
      DnsRecord.new patch("/directory/v1/org/#{org_id}/domains/#{domain}/dns/#{record_id}", body: dns_record).body
    end

    def delete(org_id:, domain:, record_id:)
      validate_required_params({org_id: org_id, domain: domain, record_id: record_id}, [:org_id, :domain, :record_id])
      Object.new delete_request("/directory/v1/org/#{org_id}/domains/#{domain}/dns/#{record_id}").body
    end
  end
end