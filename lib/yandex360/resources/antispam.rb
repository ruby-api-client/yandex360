# frozen_string_literal: true

module Yandex360
  class AntispamResource < Resource
    def list(org_id:)
      AllowList.new get("/admin/v1/org/#{org_id}/mail/antispam/allowlist/ips").body
    end

    def create(org_id, *strings)
      body = {allowList: strings}
      AllowList.new post("admin/v1/org/#{org_id}/mail/antispam/allowlist/ips", body: body).body
    end

    def delete(org_id:)
      delete_request("admin/v1/org/#{org_id}/mail/antispam/allowlist/ips")
    end
  end
end
