# frozen_string_literal: true

module Yandex360
  # Per-employee mail settings: automatic contact collection, the sender name
  # and signatures, and the auto-reply and forwarding rules.
  #
  # All three live under /admin/v1/org/{orgId}/mail/users/{userId}/settings.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/MailUserSettingsService/
  class MailSettingsResource < Resource
    include ParamBuilder

    def address_book(org_id:, user_id:)
      MailAddressBook.new get(settings_path(org_id, user_id, "address_book")).body
    end

    def update_address_book(org_id:, user_id:, collect_addresses:)
      required = {org_id: org_id, user_id: user_id}
      validate_required_params(required, %i[org_id user_id])
      body = {collectAddresses: collect_addresses}
      MailAddressBook.new post(settings_path(org_id, user_id, "address_book"), body: body).body
    end

    def sender_info(org_id:, user_id:)
      MailSenderInfo.new get(settings_path(org_id, user_id, "sender_info")).body
    end

    # Accepts from_name, default_from, signs and sign_position; the API
    # documents them in camelCase, so they are converted here.
    def update_sender_info(org_id:, user_id:, **params)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      body = camelize(build_params({}, params))
      MailSenderInfo.new post(settings_path(org_id, user_id, "sender_info"), body: body).body
    end

    # Auto-reply and forwarding rules arrive together, under separate keys.
    def rules(org_id:, user_id:)
      MailUserRules.new get(settings_path(org_id, user_id, "user_rules")).body
    end

    # One rule per call, and of one kind: an auto-reply takes rule_name and
    # text, a forward takes rule_name, address and with_store.
    def create_rule(org_id:, user_id:, **params)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      raise ArgumentError, "Provide the rule attributes" if params.empty?

      body = camelize(build_params({}, params))
      MailRule.new post(settings_path(org_id, user_id, "user_rules"), body: body).body
    end

    def delete_rule(org_id:, user_id:, rule_id:)
      required = {org_id: org_id, user_id: user_id, rule_id: rule_id}
      validate_required_params(required, %i[org_id user_id rule_id])
      Response.new delete_request("#{settings_path(org_id, user_id, 'user_rules')}/#{rule_id}").body
    end

    private

    def settings_path(org_id, user_id, setting)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      "/admin/v1/org/#{org_id}/mail/users/#{user_id}/settings/#{setting}"
    end

    # Callers write snake_case here as they do everywhere else in the gem.
    def camelize(params)
      params.transform_keys do |key|
        head, *rest = key.to_s.split("_")
        [head, *rest.map(&:capitalize)].join.to_sym
      end
    end
  end
end
