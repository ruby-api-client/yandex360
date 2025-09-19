# frozen_string_literal: true

module Yandex360
  class UsersResource < Resource
    include ParamBuilder
    def add(org_id:, dep_id:, **user_params)
      validate_required_params({org_id: org_id, dep_id: dep_id}, [:org_id, :dep_id])
      user = build_user_params({departmentId: dep_id}, user_params)

      User.new post("/directory/v1/org/#{org_id}/users", body: user).body
    end

    def add_alias(org_id:, user_id:, user_alias:)
      validate_required_params({org_id: org_id, user_id: user_id, user_alias: user_alias}, [:org_id, :user_id, :user_alias])
      body = {alias: user_alias}
      User.new post("/directory/v1/org/#{org_id}/users/#{user_id}/aliases", body: body).body
    end

    def update(org_id:, user_id:, **user_params)
      validate_required_params({org_id: org_id, user_id: user_id}, [:org_id, :user_id])
      user = build_user_params({}, user_params)

      User.new patch("/directory/v1/org/#{org_id}/users/#{user_id}", body: user).body
    end

    def info(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, [:org_id, :user_id])
      User.new get("/directory/v1/org/#{org_id}/users/#{user_id}").body
    end

    def list(org_id:, page: 1, per_page: 10)
      validate_required_params({org_id: org_id}, [:org_id])
      params = {page: page, perPage: per_page}
      resp = get("/directory/v1/org/#{org_id}/users", params: params)
      Collection.from_response(resp, key: "users", type: User)
    end

    # rubocop:disable Naming/MethodName
    def get2FA(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, [:org_id, :user_id])
      # TODO: add User2FA.new type
      Object.new get("/directory/v1/org/#{org_id}/users/#{user_id}/2fa").body
    end

    def has2FA?(org_id:, user_id:)
      get2FA(org_id: org_id, user_id: user_id).has2fa
    end
    # rubocop:enable Naming/MethodName

    def delete(org_id:, user_id:)
      validate_required_params({org_id: org_id, user_id: user_id}, [:org_id, :user_id])
      User.new delete_request("/directory/v1/org/#{org_id}/users/#{user_id}").body
    end

    def delete_alias(org_id:, user_id:, user_alias:)
      validate_required_params({org_id: org_id, user_id: user_id, user_alias: user_alias}, [:org_id, :user_id, :user_alias])
      Alias.new delete_request("/directory/v1/org/#{org_id}/users/#{user_id}/aliases/#{user_alias}").body
    end

    private

    def build_user_params(base_params, additional_params)
      build_params(base_params, additional_params)
    end
  end
end
