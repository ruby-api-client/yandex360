# frozen_string_literal: true

module Yandex360
  class PostSettingsResource < Resource
    include ParamBuilder

    def list(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      Object.new get("/directory/v1/org/#{org_id}/users/#{user_id}/settings/mail").body
    end

    def update(org_id:, user_id:, **params)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      settings = build_params({}, params)
      Object.new patch("/directory/v1/org/#{org_id}/users/#{user_id}/settings/mail", body: settings).body
    end

    def forwarding_list(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      resp = get("/directory/v1/org/#{org_id}/users/#{user_id}/settings/mail/forwarding")
      Collection.from_response(resp, key: "forwardings", type: Object)
    end

    def add_forwarding(org_id:, user_id:, address:)
      validate_required_params({org_id: org_id, user_id: user_id, address: address}, %i[org_id user_id address])
      body = {address: address}
      Object.new post("/directory/v1/org/#{org_id}/users/#{user_id}/settings/mail/forwarding", body: body).body
    end

    def delete_forwarding(org_id:, user_id:, address:)
      validate_required_params({org_id: org_id, user_id: user_id, address: address}, %i[org_id user_id address])
      Object.new delete_request("/directory/v1/org/#{org_id}/users/#{user_id}/settings/mail/forwarding/#{address}").body
    end
  end
end
