# frozen_string_literal: true

module Yandex360
  # Domain level rules for incoming mail: which senders are accepted, rejected
  # or forced to spam.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/DomainPolicies/
  class DomainPoliciesResource < Resource
    def list(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      DomainPolicy.new get("/admin/v1/org/#{org_id}/mail/routing/policies").body
    end

    # Replaces the whole rule set: the API takes the full list, not a patch,
    # so anything left out is removed.
    def set(org_id:, rules:)
      validate_required_params({org_id: org_id, rules: rules}, %i[org_id rules])
      Response.new put("/admin/v1/org/#{org_id}/mail/routing/policies", body: {rules: rules}).body
    end
  end
end
