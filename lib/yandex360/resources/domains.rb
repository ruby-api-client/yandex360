# frozen_string_literal: true

module Yandex360
  class DomainsResource < Resource
    include ParamBuilder

    def list(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      resp = get("/directory/v1/org/#{org_id}/domains")
      Collection.from_response(resp, key: "domains", type: Domain)
    end

    def add(org_id:, name:, **params)
      validate_required_params({org_id: org_id, name: name}, %i[org_id name])
      domain = build_params({name: name}, params)
      Domain.new post("/directory/v1/org/#{org_id}/domains", body: domain).body
    end

    def info(org_id:, domain:)
      validate_required_params({org_id: org_id, domain: domain}, %i[org_id domain])
      Domain.new get("/directory/v1/org/#{org_id}/domains/#{domain}").body
    end

    def delete(org_id:, domain:)
      validate_required_params({org_id: org_id, domain: domain}, %i[org_id domain])
      Object.new delete_request("/directory/v1/org/#{org_id}/domains/#{domain}").body
    end

    def verify(org_id:, domain:)
      validate_required_params({org_id: org_id, domain: domain}, %i[org_id domain])
      Domain.new post("/directory/v1/org/#{org_id}/domains/#{domain}/verify", body: {}).body
    end
  end
end
