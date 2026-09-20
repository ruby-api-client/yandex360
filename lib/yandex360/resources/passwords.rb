# frozen_string_literal: true

module Yandex360
  # Password policy for the organization: whether users may change their own
  # password, and how long a password stays valid.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/DomainPasswordsService/
  class PasswordsResource < Resource
    def info(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      DomainPassword.new get("/security/v1/org/#{org_id}/domain_passwords").body
    end

    # The API accepts either field on its own, but rejects an empty body, so
    # nil values are dropped rather than sent.
    def update(org_id:, enabled: nil, change_frequency: nil)
      validate_required_params({org_id: org_id}, [:org_id])
      body = {}
      body[:enabled] = enabled unless enabled.nil?
      body[:changeFrequency] = change_frequency unless change_frequency.nil?
      raise ArgumentError, "Provide enabled or change_frequency" if body.empty?

      DomainPassword.new put("/security/v1/org/#{org_id}/domain_passwords", body: body).body
    end
  end
end
