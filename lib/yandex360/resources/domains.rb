# frozen_string_literal: true

module Yandex360
  # Domains, their connection status and their DKIM signature.
  #
  # There is no endpoint for reading one domain: the service offers a list and
  # nothing narrower, so #find filters what the list returns.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/DomainService/
  class DomainsResource < Resource
    include ParamBuilder

    # per_page is capped at 10 by the API.
    def list(org_id:, page: 1, per_page: 10)
      validate_required_params({org_id: org_id}, [:org_id])
      resp = get("/directory/v1/org/#{org_id}/domains", params: {page: page, perPage: per_page})
      Collection.from_response(resp, key: "domains", type: Domain) do |next_page|
        list(org_id: org_id, page: next_page, per_page: per_page)
      end
    end

    # Walks the list until the name matches, because the API has nothing to ask
    # for a single domain with. Costs one request per page rather than one.
    def find(org_id:, domain:)
      validate_required_params({org_id: org_id, domain: domain}, %i[org_id domain])
      list(org_id: org_id).auto_paginate.find {|candidate| candidate.name == domain }
    end

    def add(org_id:, name:, **params)
      validate_required_params({org_id: org_id, name: name}, %i[org_id name])
      domain = build_params({name: name}, params)
      Domain.new post("/directory/v1/org/#{org_id}/domains", body: domain).body
    end

    def delete(org_id:, domain:)
      validate_required_params({org_id: org_id, domain: domain}, %i[org_id domain])
      Response.new delete_request(domain_path(org_id, domain)).body
    end

    # Carries the confirmation methods and their codes, which is what domain
    # verification actually needs.
    def connection_status(org_id:, domain:)
      DomainStatus.new get("#{domain_path(org_id, domain)}/status").body
    end

    def dkim_status(org_id:, domain:)
      DomainDkim.new get("#{domain_path(org_id, domain)}/dkim").body
    end

    def enable_dkim(org_id:, domain:)
      Response.new post("#{domain_path(org_id, domain)}/dkim/enable", body: {}).body
    end

    def disable_dkim(org_id:, domain:)
      Response.new post("#{domain_path(org_id, domain)}/dkim/disable", body: {}).body
    end

    private

    # Cyrillic domains have to be given in Punycode, as the API documents.
    def domain_path(org_id, domain)
      validate_required_params({org_id: org_id, domain: domain}, %i[org_id domain])
      "/directory/v1/org/#{org_id}/domains/#{domain}"
    end
  end
end
