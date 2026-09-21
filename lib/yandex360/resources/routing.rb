# frozen_string_literal: true

module Yandex360
  # Domain level mail processing rules: drop or forward messages matching a
  # condition, inbound or outbound.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/RoutingService/
  class RoutingResource < Resource
    def list(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      RoutingRules.new get("/admin/v1/org/#{org_id}/mail/routing/rules").body
    end

    # Replaces the whole rule set, like DomainPolicies#set: rules left out are
    # removed rather than kept.
    def set(org_id:, rules:)
      validate_required_params({org_id: org_id, rules: rules}, %i[org_id rules])
      Response.new put("/admin/v1/org/#{org_id}/mail/routing/rules", body: {rules: rules}).body
    end
  end
end
