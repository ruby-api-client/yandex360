# frozen_string_literal: true

module Yandex360
  class DepartmentsResource < Resource
    include ParamBuilder
    def add_alias(org_id:, dep_id:, name:)
      validate_required_params({org_id: org_id, dep_id: dep_id, name: name}, [:org_id, :dep_id, :name])
      dep_alias = {alias: name}
      DepartmentAlias.new post("/directory/v1/org/#{org_id}/departments/#{dep_id}/aliases", body: dep_alias).body
    end

    def update(org_id:, dep_id:, parent_id:, **params)
      validate_required_params({org_id: org_id, dep_id: dep_id, parent_id: parent_id}, [:org_id, :dep_id, :parent_id])
      department = build_department_params({
        orgId: org_id,
        departmentId: dep_id,
        parentId: parent_id
      }, params)
      Department.new patch("/directory/v1/org/#{org_id}/departments/#{dep_id}", body: department).body
    end

    def info(org_id:, dep_id:)
      validate_required_params({org_id: org_id, dep_id: dep_id}, [:org_id, :dep_id])
      Department.new get("/directory/v1/org/#{org_id}/departments/#{dep_id}").body
    end

    def list(org_id:, page: 1, per_page: 10, parent_id: 0, order_by: "id")
      validate_required_params({org_id: org_id}, [:org_id])
      params = {
        page: page,
        perPage: per_page,
        parentId: parent_id,
        orderBy: order_by
      }
      resp = get("/directory/v1/org/#{org_id}/departments", params: params)
      Collection.from_response(resp, key: "departments", type: Department)
    end

    # parent_id:, name:, description: "", external_id: "", head_id: 0, label: ""
    def create(org_id:, name:, parent_id:, **params)
      validate_required_params({org_id: org_id, name: name, parent_id: parent_id}, [:org_id, :name, :parent_id])
      department = build_department_params({
        parentId: parent_id,
        name: name
      }, params)

      Department.new post("/directory/v1/org/#{org_id}/departments", body: department).body
    end

    def delete_alias(org_id:, dep_id:, name:)
      validate_required_params({org_id: org_id, dep_id: dep_id, name: name}, [:org_id, :dep_id, :name])
      Object.new delete_request("/directory/v1/org/#{org_id}/departments/#{dep_id}/aliases/#{name}").body
    end

    def delete(org_id:, dep_id:)
      validate_required_params({org_id: org_id, dep_id: dep_id}, [:org_id, :dep_id])
      Object.new delete_request("/directory/v1/org/#{org_id}/departments/#{dep_id}").body
    end

    private

    def build_department_params(base_params, additional_params)
      build_params(base_params, additional_params)
    end
  end
end
