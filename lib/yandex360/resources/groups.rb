# frozen_string_literal: true

module Yandex360
  class GroupsResource < Resource
    def add_user(org_id:, group_id:, id:, type: "user")
      user = {
        id: id,
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
      Collection.from_response(resp, key: "groups", type: Object)
    end

    def users(org_id:, group_id:)
      # TODO: GroupUserList.new type
      Object.new get("directory/v1/org/#{org_id}/groups/#{group_id}/members").body
    end

    def create(org_id:, **group_params)
      group = {}
      group_params.each {|param, value| group[param] = value }
      Group.new post("directory/v1/org/#{org_id}/groups", body: group).body
    end

    def delete(org_id:, group_id:)
      delete_request("directory/v1/org/#{org_id}/groups/#{group_id}")
    end

    def delete_user(org_id:, group_id:, type:, id:)
      Object.new delete_request("directory/v1/org/#{org_id}/groups/#{group_id}/members/#{type}/#{id}").body
    end
  end
end
