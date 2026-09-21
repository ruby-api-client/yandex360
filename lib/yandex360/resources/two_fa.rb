# frozen_string_literal: true

module Yandex360
  # Mandatory two-factor authentication for the whole organization.
  #
  # All three operations share one path and differ only by verb, which is why
  # there is no separate enable or disable endpoint to call.
  #
  # Per-employee two-factor authentication is not here: reading it is
  # users.get2FA and clearing the phone is users.delete_2fa_phone, both on
  # UserService.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/Domain2FAService/
  class TwoFaResource < Resource
    include ParamBuilder

    def status(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      Domain2FA.new get(domain_path(org_id)).body
    end

    # duration is how long, in seconds, an employee may postpone setting 2FA up
    # during sign-in. validation_method is "default" or "phone".
    def enable(org_id:, duration:, logout_users: nil, validation_method: nil)
      validate_required_params({org_id: org_id, duration: duration}, %i[org_id duration])
      body = {duration: duration}
      body[:logoutUsers] = logout_users unless logout_users.nil?
      body[:validationMethod] = validation_method unless validation_method.nil?

      Domain2FA.new post(domain_path(org_id), body: body).body
    end

    def disable(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      Domain2FA.new delete_request(domain_path(org_id)).body
    end

    # Deprecated: the name #status carried before this resource was corrected.
    # Removed in 5.0.
    def domain_status(org_id:)
      warn "[yandex360] two_fa.domain_status is deprecated, use two_fa.status", uplevel: 1
      status(org_id: org_id)
    end

    private

    def domain_path(org_id)
      "/security/v1/org/#{org_id}/domain_2fa"
    end
  end
end
