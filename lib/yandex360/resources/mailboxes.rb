# frozen_string_literal: true

module Yandex360
  # Shared and delegated mailboxes, and the access rights on them.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/MailboxService/
  class MailboxesResource < Resource
    include ParamBuilder

    def shared_list(org_id:, page: 1, per_page: 10)
      validate_required_params({org_id: org_id}, [:org_id])
      resp = get("/admin/v1/org/#{org_id}/mailboxes/shared", params: {page: page, perPage: per_page})
      Collection.from_response(resp, key: "resources", type: MailboxResource) do |next_page|
        shared_list(org_id: org_id, page: next_page, per_page: per_page)
      end
    end

    def create_shared(org_id:, email:, name:, description:)
      required = {org_id: org_id, email: email, name: name, description: description}
      validate_required_params(required, %i[org_id email name description])
      body = {email: email, name: name, description: description}
      Mailbox.new put("/admin/v1/org/#{org_id}/mailboxes/shared", body: body).body
    end

    def shared_info(org_id:, resource_id:)
      validate_required_params({org_id: org_id, resource_id: resource_id}, %i[org_id resource_id])
      Mailbox.new get("/admin/v1/org/#{org_id}/mailboxes/shared/#{resource_id}").body
    end

    def update_shared(org_id:, resource_id:, **params)
      validate_required_params({org_id: org_id, resource_id: resource_id}, %i[org_id resource_id])
      body = build_params({}, params)
      Mailbox.new put("/admin/v1/org/#{org_id}/mailboxes/shared/#{resource_id}", body: body).body
    end

    def delete_shared(org_id:, resource_id:)
      validate_required_params({org_id: org_id, resource_id: resource_id}, %i[org_id resource_id])
      Response.new delete_request("/admin/v1/org/#{org_id}/mailboxes/shared/#{resource_id}").body
    end

    def delegated_list(org_id:, page: 1, per_page: 10)
      validate_required_params({org_id: org_id}, [:org_id])
      resp = get("/admin/v1/org/#{org_id}/mailboxes/delegated", params: {page: page, perPage: per_page})
      Collection.from_response(resp, key: "resources", type: MailboxResource) do |next_page|
        delegated_list(org_id: org_id, page: next_page, per_page: per_page)
      end
    end

    def create_delegated(org_id:, resource_id:)
      validate_required_params({org_id: org_id, resource_id: resource_id}, %i[org_id resource_id])
      body = {resourceId: resource_id}
      Mailbox.new put("/admin/v1/org/#{org_id}/mailboxes/delegated", body: body).body
    end

    def delete_delegated(org_id:, resource_id:)
      validate_required_params({org_id: org_id, resource_id: resource_id}, %i[org_id resource_id])
      Response.new delete_request("/admin/v1/org/#{org_id}/mailboxes/delegated/#{resource_id}").body
    end

    # Employees who can reach the given mailbox.
    def actors(org_id:, resource_id:)
      validate_required_params({org_id: org_id, resource_id: resource_id}, %i[org_id resource_id])
      resp = get("/admin/v1/org/#{org_id}/mailboxes/actors/#{resource_id}")
      Collection.from_response(resp, key: "actors", type: MailboxActor)
    end

    # Mailboxes the given employee can reach.
    def resources(org_id:, actor_id:)
      validate_required_params({org_id: org_id, actor_id: actor_id}, %i[org_id actor_id])
      resp = get("/admin/v1/org/#{org_id}/mailboxes/resources/#{actor_id}")
      Collection.from_response(resp, key: "resources", type: MailboxResource)
    end

    # Applies asynchronously. The returned taskId is polled through #task_status.
    # notify is one of "all", "delegates" or "none".
    def set_access(org_id:, resource_id:, actor_id:, roles:, notify: nil)
      required = {org_id: org_id, resource_id: resource_id, actor_id: actor_id, roles: roles}
      validate_required_params(required, %i[org_id resource_id actor_id roles])
      params = {actorId: actor_id}
      params[:notify] = notify if notify
      resp = post("/admin/v1/org/#{org_id}/mailboxes/set/#{resource_id}",
                  body: {roles: roles}, params: params)
      MailboxTask.new resp.body
    end

    def task_status(org_id:, task_id:)
      validate_required_params({org_id: org_id, task_id: task_id}, %i[org_id task_id])
      MailboxTask.new get("/admin/v1/org/#{org_id}/mailboxes/tasks/#{task_id}").body
    end
  end
end
