# frozen_string_literal: true

module Yandex360
  class GroupsResource < Resource
    def add_user(org_id:, group_id:, user_id:, type: "user")
      user = {
        id: user_id,
        type: type
      }
      Group.new post("directory/v1/org/#{org_id}/groups/#{group_id}/members", body: user).body
    end

    def update(org_id:, group_id:, **user_params)
      user = {}
      user_params.each {|param, value| user[param] = value }
      Group.new patch("directory/v1/org/#{org_id}/groups/#{group_id}", body: user).body
    end

    def params(org_id:, group_id:)
      Group.new get("directory/v1/org/#{org_id}/groups/#{group_id}").body
    end

    def list(org_id:, page: 1, per_page: 10)
      resp = get("directory/v1/org/#{org_id}/groups?page=#{page}&perPage=#{per_page}")
      Collection.from_response(resp, key: "groups", type: Group)
    end

    def users(org_id:, group_id:)
      resp = get("directory/v1/org/#{org_id}/groups/#{group_id}/members")
      Collection.from_response(resp, key: "users", type: User)
    end

    def create(org_id:, name:, **group_params)
      group = {
        name: name
      }
      group_params.each {|param, value| group[param] = value }
      Group.new post("directory/v1/org/#{org_id}/groups", body: group).body
    end

    def delete(org_id:, group_id:)
      Group.new delete_request("directory/v1/org/#{org_id}/groups/#{group_id}").body
    end

    def delete_user(org_id:, group_id:, type:, user_id:)
      Object.new delete_request("directory/v1/org/#{org_id}/groups/#{group_id}/members/#{type}/#{user_id}").body
    end
  end
end
