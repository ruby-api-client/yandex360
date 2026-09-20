# frozen_string_literal: true

module Yandex360
  # Session cookie lifetime for the organization, and forced sign-out.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/DomainSessionsService/
  class SessionsResource < Resource
    def info(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      DomainSession.new get("/security/v1/org/#{org_id}/domain_sessions").body
    end

    # auth_ttl is in seconds. Zero means sessions never expire.
    def update(org_id:, auth_ttl:)
      validate_required_params({org_id: org_id, auth_ttl: auth_ttl}, %i[org_id auth_ttl])
      body = {authTTL: auth_ttl}
      DomainSession.new post("/security/v1/org/#{org_id}/domain_sessions", body: body).body
    end

    # Signs the user out everywhere. The endpoint takes no body.
    def logout(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      Object.new put("/security/v1/org/#{org_id}/domain_sessions/users/#{user_id}/logout", body: {}).body
    end
  end
end
