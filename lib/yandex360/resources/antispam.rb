# frozen_string_literal: true

module Yandex360
  class AntispamResource < Resource
    def list(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      AllowList.new get("/admin/v1/org/#{org_id}/mail/antispam/allowlist/ips").body
    end

    def create(org_id, *strings)
      validate_required_params({org_id: org_id}, [:org_id])
      raise ArgumentError, "At least one IP address must be provided" if strings.empty?

      # Filter out empty strings
      valid_strings = strings.compact.reject { |s| s.to_s.strip.empty? }
      raise ArgumentError, "At least one valid IP address must be provided" if valid_strings.empty?

      body = {allowList: valid_strings}
      AllowList.new post("/admin/v1/org/#{org_id}/mail/antispam/allowlist/ips", body: body).body
    end

    def delete(org_id:)
      validate_required_params({org_id: org_id}, [:org_id])
      delete_request("/admin/v1/org/#{org_id}/mail/antispam/allowlist/ips")
    end
  end
end
