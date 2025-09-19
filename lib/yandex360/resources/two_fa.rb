# frozen_string_literal: true

module Yandex360
  class TwoFaResource < Resource
    def enable(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, [:org_id, :user_id])
      Object.new post("/security/v1/org/#{org_id}/users/#{user_id}/2fa/enable", body: {}).body
    end

    def disable(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, [:org_id, :user_id])
      Object.new post("/security/v1/org/#{org_id}/users/#{user_id}/2fa/disable", body: {}).body
    end

    def status(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, [:org_id, :user_id])
      Object.new get("/security/v1/org/#{org_id}/users/#{user_id}/2fa/status").body
    end

    def domain_status(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      Object.new get("/security/v1/org/#{org_id}/domain_2fa").body
    end

    def configure_domain(org_id:, enabled:)
      validate_required_params({org_id: org_id, enabled: enabled}, [:org_id, :enabled])
      body = {enabled: enabled}
      Object.new post("/security/v1/org/#{org_id}/domain_2fa", body: body).body
    end
  end
end