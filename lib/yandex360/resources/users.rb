# frozen_string_literal: true

module Yandex360
  class UsersResource < Resource
    include ParamBuilder
    def add(org_id:, dep_id:, **user_params)
      validate_required_params({org_id: org_id, dep_id: dep_id}, %i[org_id dep_id])
      user = build_params({departmentId: dep_id}, user_params)

      User.new post("/directory/v1/org/#{org_id}/users", body: user).body
    end

    def add_alias(org_id:, user_id:, user_alias:)
      validate_required_params({org_id: org_id, user_id: user_id, user_alias: user_alias},
                               %i[org_id user_id user_alias])
      body = {alias: user_alias}
      User.new post("/directory/v1/org/#{org_id}/users/#{user_id}/aliases", body: body).body
    end

    def update(org_id:, user_id:, **user_params)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      user = build_params({}, user_params)

      User.new patch("/directory/v1/org/#{org_id}/users/#{user_id}", body: user).body
    end

    def info(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      User.new get("/directory/v1/org/#{org_id}/users/#{user_id}").body
    end

    def list(org_id:, page: 1, per_page: 10)
      validate_required_params({org_id: org_id}, [:org_id])
      params = {page: page, perPage: per_page}
      resp = get("/directory/v1/org/#{org_id}/users", params: params)
      Collection.from_response(resp, key: "users", type: User) do |next_page|
        list(org_id: org_id, page: next_page, per_page: per_page)
      end
    end

    # rubocop:disable Naming/MethodName
    def get2FA(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      User2FA.new get("/directory/v1/org/#{org_id}/users/#{user_id}/2fa").body
    end

    def has2FA?(org_id:, user_id:)
      get2FA(org_id: org_id, user_id: user_id).has2fa
    end
    # rubocop:enable Naming/MethodName

    # Removes the phone configured for two-factor authentication. The API
    # answers 400 when the employee has no phone set.
    #
    # Named in snake_case unlike get2FA above: that name needed a lint
    # suppression, and matching it would spread the exception further.
    def delete_2fa_phone(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      Object.new delete_request("/directory/v1/org/#{org_id}/users/#{user_id}/2fa").body
    end

    # The body is the raw image, not JSON and not multipart, so the content
    # type has to be set explicitly for the JSON middleware to leave it alone.
    def update_avatar(org_id:, user_id:, image:, content_type: "image/png")
      validate_required_params({org_id: org_id, user_id: user_id, image: image},
                               %i[org_id user_id image])
      resp = put("/directory/v1/org/#{org_id}/users/#{user_id}/avatar",
                 body: image, headers: {"Content-Type" => content_type})
      Object.new resp.body
    end

    # Replaces the contact list. Entries the API generated itself, marked
    # synthetic, cannot be changed or removed.
    def update_contacts(org_id:, user_id:, contacts:)
      validate_required_params({org_id: org_id, user_id: user_id, contacts: contacts},
                               %i[org_id user_id contacts])
      resp = put("/directory/v1/org/#{org_id}/users/#{user_id}/contacts",
                 body: {contacts: contacts})
      User.new resp.body
    end

    def delete_contacts(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      User.new delete_request("/directory/v1/org/#{org_id}/users/#{user_id}/contacts").body
    end

    def delete(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, %i[org_id user_id])
      User.new delete_request("/directory/v1/org/#{org_id}/users/#{user_id}").body
    end

    def delete_alias(org_id:, user_id:, user_alias:)
      validate_required_params({org_id: org_id, user_id: user_id, user_alias: user_alias},
                               %i[org_id user_id user_alias])
      Alias.new delete_request("/directory/v1/org/#{org_id}/users/#{user_id}/aliases/#{user_alias}").body
    end
  end
end
