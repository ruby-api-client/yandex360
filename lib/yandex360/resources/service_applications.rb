# frozen_string_literal: true

module Yandex360
  # Service applications and the scopes granted to them.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/ServiceApplicationsService/
  class ServiceApplicationsResource < Resource
    def list(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      resp = get("/security/v1/org/#{org_id}/service_applications")
      Collection.from_response(resp, key: "applications", type: ServiceApplication)
    end

    # Replaces the stored list with the one given.
    def create(org_id:, applications:)
      validate_required_params({org_id: org_id, applications: applications}, %i[org_id applications])
      resp = post("/security/v1/org/#{org_id}/service_applications", body: {applications: applications})
      Collection.from_response(resp, key: "applications", type: ServiceApplication)
    end

    # Clears the whole list. There is no per-application delete.
    def delete(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      resp = delete_request("/security/v1/org/#{org_id}/service_applications")
      Collection.from_response(resp, key: "applications", type: ServiceApplication)
    end

    def activate(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      Object.new post("/security/v1/org/#{org_id}/service_applications/activate", body: {}).body
    end

    def deactivate(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      Object.new post("/security/v1/org/#{org_id}/service_applications/deactivate", body: {}).body
    end
  end
end
