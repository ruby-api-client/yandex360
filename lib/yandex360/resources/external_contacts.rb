# frozen_string_literal: true

module Yandex360
  # Shared contacts outside the organization.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/ExternalContactService/
  class ExternalContactsResource < Resource
    include ParamBuilder

    def list(org_id:, page: 1, per_page: 10)
      validate_required_params({org_id: org_id}, [:org_id])
      resp = get("/directory/v1/org/#{org_id}/external_contacts",
                 params: {page: page, perPage: per_page})
      Collection.from_response(resp, key: "contacts", type: ExternalContact) do |next_page|
        list(org_id: org_id, page: next_page, per_page: per_page)
      end
    end

    # emails must hold at least one entry; the API rejects a contact without one.
    def create(org_id:, first_name:, last_name:, emails:, **params)
      required = {org_id: org_id, first_name: first_name, last_name: last_name, emails: emails}
      validate_required_params(required, %i[org_id first_name last_name emails])
      body = build_params({firstName: first_name, lastName: last_name, emails: emails}, params)
      ExternalContact.new post("/directory/v1/org/#{org_id}/external_contacts", body: body).body
    end

    def info(org_id:, contact_id:)
      validate_required_params({org_id: org_id, contact_id: contact_id}, %i[org_id contact_id])
      ExternalContact.new get("/directory/v1/org/#{org_id}/external_contacts/#{contact_id}").body
    end

    # PATCH, so only the fields given are touched. Emails and phones are not
    # editable here: they have their own endpoints below.
    def update(org_id:, contact_id:, **params)
      validate_required_params({org_id: org_id, contact_id: contact_id}, %i[org_id contact_id])
      body = build_params({}, params)
      resp = patch("/directory/v1/org/#{org_id}/external_contacts/#{contact_id}", body: body)
      ExternalContact.new resp.body
    end

    def delete(org_id:, contact_id:)
      validate_required_params({org_id: org_id, contact_id: contact_id}, %i[org_id contact_id])
      Response.new delete_request("/directory/v1/org/#{org_id}/external_contacts/#{contact_id}").body
    end

    # Replaces the address list entirely. It cannot be empty and exactly one
    # entry must carry main: true.
    def update_emails(org_id:, contact_id:, emails:)
      required = {org_id: org_id, contact_id: contact_id, emails: emails}
      validate_required_params(required, %i[org_id contact_id emails])
      resp = put("/directory/v1/org/#{org_id}/external_contacts/#{contact_id}/emails",
                 body: {emails: emails})
      ExternalContact.new resp.body
    end

    # Replaces the phone list entirely. At most one entry may carry main: true.
    def update_phones(org_id:, contact_id:, phones:)
      required = {org_id: org_id, contact_id: contact_id, phones: phones}
      validate_required_params(required, %i[org_id contact_id phones])
      resp = put("/directory/v1/org/#{org_id}/external_contacts/#{contact_id}/phones",
                 body: {phones: phones})
      ExternalContact.new resp.body
    end
  end
end
