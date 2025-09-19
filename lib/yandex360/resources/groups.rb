# frozen_string_literal: true

module Yandex360
  class GroupsResource < Resource
    include ParamBuilder
    def add_user(org_id:, group_id:, user_id:, type: "user")
      validate_required_params({org_id: org_id, group_id: group_id, user_id: user_id}, %i[org_id group_id user_id])
      user = {
        id: user_id,
        type: type
      }
      Group.new post("/directory/v1/org/#{org_id}/groups/#{group_id}/members", body: user).body
    end

    def update(org_id:, group_id:, **user_params)
      validate_required_params({org_id: org_id, group_id: group_id}, %i[org_id group_id])
      user = build_group_params({}, user_params)
      Group.new patch("/directory/v1/org/#{org_id}/groups/#{group_id}", body: user).body
    end

    def params(org_id:, group_id:)
      validate_required_params({org_id: org_id, group_id: group_id}, %i[org_id group_id])
      Group.new get("/directory/v1/org/#{org_id}/groups/#{group_id}").body
    end

    def list(org_id:, page: 1, per_page: 10)
      validate_required_params({org_id: org_id}, [:org_id])
      params = {page: page, perPage: per_page}
      resp = get("/directory/v1/org/#{org_id}/groups", params: params)
      Collection.from_response(resp, key: "groups", type: Group)
    end

    def users(org_id:, group_id:)
      validate_required_params({org_id: org_id, group_id: group_id}, %i[org_id group_id])
      resp = get("/directory/v1/org/#{org_id}/groups/#{group_id}/members")
      Collection.from_response(resp, key: "users", type: User)
    end

    def create(org_id:, name:, **group_params)
      validate_required_params({org_id: org_id, name: name}, %i[org_id name])
      group = build_group_params({name: name}, group_params)
      Group.new post("/directory/v1/org/#{org_id}/groups", body: group).body
    end

    def delete(org_id:, group_id:)
      validate_required_params({org_id: org_id, group_id: group_id}, %i[org_id group_id])
      Group.new delete_request("/directory/v1/org/#{org_id}/groups/#{group_id}").body
    end

    def delete_user(org_id:, group_id:, type:, user_id:)
      validate_required_params({org_id: org_id, group_id: group_id, type: type, user_id: user_id},
                               %i[org_id group_id type user_id])
      Object.new delete_request("/directory/v1/org/#{org_id}/groups/#{group_id}/members/#{type}/#{user_id}").body
    end

    private

    def build_group_params(base_params, additional_params)
      build_params(base_params, additional_params)
    end
  end
end
