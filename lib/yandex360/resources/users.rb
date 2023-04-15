# frozen_string_literal: true

module Yandex360
  class UsersResource < Resource
    def add(org_id:, dep_id:, **user_params)
      user = {
        departmentId: dep_id
      }
      user_params.each {|param, value| user[param] = value }

      User.new post("directory/v1/org/#{org_id}/users", body: user).body
    end

    def add_alias(org_id:, user_id:, user_alias:)
      body = {alias: user_alias}
      User.new post("directory/v1/org/#{org_id}/users/#{user_id}/aliases", body: body).body
    end

    def update(org_id:, user_id:, **user_params)
      user = {}
      user_params.each {|param, value| user[param] = value }

      User.new patch("directory/v1/org/#{org_id}/users/#{user_id}", body: user).body
    end

    def info(org_id:, user_id:)
      User.new get("directory/v1/org/#{org_id}/users/#{user_id}").body
    end

    def list(org_id:, page: 1, per_page: 10)
      resp = get("directory/v1/org/#{org_id}/users?page=#{page}&perPage=#{per_page}")
      Collection.from_response(resp, key: "users", type: User)
    end

    # rubocop:disable Naming/MethodName
    def get2FA(org_id:, user_id:)
      # TODO: add User2FA.new type
      Object.new get("directory/v1/org/#{org_id}/users/#{user_id}/2fa").body
    end

    def has2FA?(org_id:, user_id:)
      get2FA(org_id: org_id, user_id: user_id).has2fa
    end
    # rubocop:enable Naming/MethodName

    def delete(org_id:, user_id:)
      User.new delete_request("/directory/v1/org/#{org_id}/users/#{user_id}/contacts").body
    end

    def delete_alias(org_id:, user_id:, user_alias:)
      Alias.new delete_request("directory/v1/org/#{org_id}/users/#{user_id}/aliases/#{user_alias}").body
    end
  end
end
