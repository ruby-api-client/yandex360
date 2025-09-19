# frozen_string_literal: true

require "faraday"

module HttpStubs
  def stub_client
    @stubs ||= Faraday::Adapter::Test::Stubs.new
    @client ||= Yandex360::Client.new(token: "test_token", adapter: :test, stubs: @stubs)
    [@client, @stubs]
  end

  def reset_stubs
    @stubs = nil
    @client = nil
  end

  def mock_response(body:, status: 200, headers: {})
    default_headers = {"content-type" => "application/json; charset=utf-8"}
    [status, default_headers.merge(headers), body.to_json]
  end

  def mock_error_response(status:, message: "Error")
    body = {"error" => message}
    [status, {"content-type" => "application/json; charset=utf-8"}, body.to_json]
  end

  # Organization responses
  def mock_organizations_list
    {
      "organizations" => [
        {"id" => "1130000018743049", "name" => "Test Organization", "domain" => "example.com"}
      ],
      "total" => 1,
      "items" => 1
    }
  end

  def mock_organization_info
    {
      "id" => "1130000018743049",
      "name" => "Test Organization",
      "domain" => "example.com",
      "created_at" => "2024-01-01T00:00:00Z"
    }
  end

  # User responses
  def mock_users_list
    {
      "users" => [
        {
          "id" => "1130000061922106",
          "nickname" => "ivan.ivanov",
          "name" => {"first" => "Ivan", "last" => "Ivanov"},
          "department_id" => "1",
          "position" => "Developer"
        }
      ],
      "total" => 1,
      "items" => 1
    }
  end

  def mock_user_info
    {
      "id" => "1130000061922106",
      "nickname" => "ivan.ivanov",
      "name" => {"first" => "Ivan", "last" => "Ivanov"},
      "department_id" => "1",
      "position" => "Developer",
      "contacts" => [],
      "created_at" => "2024-01-01T00:00:00Z"
    }
  end

  def mock_user_create
    {
      "id" => "1130000061922106",
      "nickname" => "ivan.ivanov",
      "name" => {"first" => "Ivan", "last" => "Yandex360"},
      "department_id" => "1"
    }
  end

  def mock_user_update
    {
      "id" => "1130000061922106",
      "nickname" => "ruby.gem",
      "name" => {"first" => "Ruby", "last" => "Yandex360 - Ruby API gem"},
      "department_id" => "1"
    }
  end

  def mock_user_alias
    {
      "alias" => "ruby_gem_api",
      "id" => "1130000061922106"
    }
  end

  def mock_user_alias_delete
    {
      "alias" => "ruby_gem_api",
      "removed" => true
    }
  end

  def mock_user_2fa
    {
      "id" => "1130000018743049",
      "has2fa" => true
    }
  end

  # Department responses
  def mock_departments_list
    {
      "departments" => [
        {
          "id" => "1",
          "name" => "IT Department",
          "parent_id" => "0",
          "head_id" => "1130000061922106"
        }
      ],
      "total" => 1,
      "items" => 1
    }
  end

  def mock_department_info
    {
      "id" => "1",
      "name" => "IT Department",
      "parent_id" => "0",
      "head_id" => "1130000061922106",
      "created_at" => "2024-01-01T00:00:00Z"
    }
  end

  def mock_department_create
    {
      "id" => "2",
      "name" => "New Department",
      "parent_id" => "1"
    }
  end

  def mock_department_alias
    {
      "alias" => "support-team",
      "department_id" => "1"
    }
  end

  def mock_department_alias_delete
    {
      "removed" => true,
      "alias" => "support-team"
    }
  end

  # Group responses
  def mock_groups_list
    {
      "groups" => [
        {
          "id" => "19",
          "name" => "Test Group",
          "description" => "Test group for API",
          "members_count" => 1
        }
      ],
      "total" => 1,
      "items" => 1
    }
  end

  def mock_group_info
    {
      "id" => "19",
      "name" => "Test Group",
      "description" => "Test group for API",
      "members_count" => 1,
      "created_at" => "2024-01-01T00:00:00Z"
    }
  end

  def mock_group_create
    {
      "id" => "19",
      "name" => "New Group",
      "description" => "Newly created group"
    }
  end

  def mock_group_add_user
    {
      "added" => true,
      "id" => "987654321",
      "type" => "user"
    }
  end

  def mock_group_users
    {
      "users" => [
        {
          "id" => "987654321",
          "nickname" => "test.user",
          "type" => "user"
        }
      ],
      "total" => 1,
      "items" => 1
    }
  end

  def mock_group_delete_user
    {
      "removed" => true,
      "type" => "user",
      "id" => "987654321"
    }
  end

  def mock_group_delete
    {
      "removed" => true,
      "id" => 19
    }
  end

  # Antispam responses
  def mock_antispam_list
    {
      "allowList" => ["127.0.0.1", "172.0.1.10"]
    }
  end

  def mock_antispam_create
    {
      "allowList" => ["127.0.0.1", "172.0.1.10"]
    }
  end

  # Domain responses
  def mock_domains_list
    {
      "domains" => [
        {"name" => "example.com", "verified" => true, "default" => true}
      ],
      "total" => 1,
      "items" => 1
    }
  end

  def mock_domain_info
    {
      "name" => "example.com",
      "verified" => true,
      "default" => true,
      "created_at" => "2024-01-01T00:00:00Z"
    }
  end

  def mock_domain_create
    {
      "name" => "newdomain.com",
      "verified" => false,
      "default" => false,
      "created_at" => "2024-01-01T00:00:00Z"
    }
  end

  # DNS responses
  def mock_dns_list
    {
      "records" => [
        {"id" => "123", "type" => "A", "name" => "test", "value" => "1.2.3.4"}
      ],
      "total" => 1,
      "items" => 1
    }
  end

  def mock_dns_create
    {
      "id" => "123",
      "type" => "A",
      "name" => "test",
      "value" => "1.2.3.4",
      "created_at" => "2024-01-01T00:00:00Z"
    }
  end

  # Two-FA responses
  def mock_two_fa_status
    {
      "enabled" => true,
      "method" => "sms"
    }
  end

  def mock_two_fa_domain_status
    {
      "enabled" => false,
      "enforced" => false
    }
  end

  # Audit responses
  def mock_audit_list
    {
      "events" => [
        {
          "id" => "audit123",
          "event_type" => "user_login",
          "user_id" => "1130000061922106",
          "timestamp" => "2024-01-01T00:00:00Z"
        }
      ],
      "total" => 1,
      "items" => 1
    }
  end

  # Post settings responses
  def mock_post_settings_list
    {
      "forwarding_enabled" => false,
      "signature" => "Best regards",
      "auto_reply_enabled" => false
    }
  end

  def mock_post_settings_forwarding_list
    {
      "forwardings" => [
        {"address" => "forward@example.com", "enabled" => true}
      ],
      "total" => 1,
      "items" => 1
    }
  end
end