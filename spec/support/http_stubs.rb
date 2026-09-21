# frozen_string_literal: true

require "faraday"

module OrganizationStubs
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
end

module UserStubs
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

  # CreateUserAlias answers the employee, with the new alias among aliases.
  def mock_user_alias
    {
      "id" => "1130000061922106",
      "nickname" => "ivan.ivanov",
      "aliases" => ["ruby_gem_api"]
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
      "userId" => "1130000018743049",
      "has2fa" => true,
      "hasSecurityPhone" => true
    }
  end
end

module DepartmentStubs
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

  # CreateAlias answers the department, with the new alias among aliases.
  def mock_department_alias
    {
      "id" => 1,
      "name" => "Support",
      "aliases" => ["support-team"]
    }
  end

  def mock_department_alias_delete
    {
      "removed" => true,
      "alias" => "support-team"
    }
  end
end

module GroupStubs
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
      "deleted" => true,
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
end

module AntispamStubs
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
end

module DomainStubs
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
end

module DnsStubs
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
end

module TwoFaStubs
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
end

module AuditStubs
  def mock_mail_audit_log(next_page_token: nil)
    body = {
      "events" => [
        {
          "eventType" => "message_receive",
          "date" => "2026-01-01T00:00:00Z",
          "orgId" => 1_130_000_018_743_049,
          "userUid" => "1130000061922106",
          "userLogin" => "ivan.ivanov",
          "subject" => "Hello"
        }
      ]
    }
    body["nextPageToken"] = next_page_token if next_page_token
    body
  end

  def mock_disk_audit_log(next_page_token: nil)
    body = {
      "events" => [
        {
          "eventType" => "fs-store",
          "date" => "2026-01-01T00:00:00Z",
          "userUid" => "1130000061922106",
          "path" => "/disk/report.xlsx",
          "size" => 2048
        }
      ]
    }
    body["nextPageToken"] = next_page_token if next_page_token
    body
  end
end

module MailSettingsStubs
  def mock_mail_address_book
    {"collectAddresses" => true}
  end

  def mock_mail_sender_info
    {
      "fromName" => "Ivan Ivanov",
      "defaultFrom" => "ivan@example.com",
      "signs" => [
        {
          "emails" => ["ivan@example.com"],
          "isDefault" => true,
          "text" => "Best regards",
          "lang" => "en"
        }
      ],
      "signPosition" => "bottom"
    }
  end

  def mock_mail_user_rules
    {
      "autoreplies" => [
        {"ruleId" => 1, "ruleName" => "On holiday", "text" => "Back on Monday"}
      ],
      "forwards" => [
        {"ruleId" => 2, "ruleName" => "To archive", "address" => "archive@example.com",
         "withStore" => true}
      ]
    }
  end

  def mock_mail_rule_created
    {"ruleId" => 3}
  end
end

module SessionStubs
  def mock_domain_session
    {"authTTL" => 86_400}
  end
end

module MailboxStubs
  def mock_shared_mailboxes_list
    {
      "resources" => [
        {"resourceId" => "1130000000000001", "count" => 3}
      ],
      "page" => 1,
      "perPage" => 10,
      "total" => 1
    }
  end

  def mock_shared_mailbox
    {
      "id" => "1130000000000001",
      "email" => "support@example.com",
      "name" => "Support",
      "description" => "Shared support mailbox",
      "createdAt" => "2026-01-01T00:00:00Z",
      "updatedAt" => "2026-01-02T00:00:00Z"
    }
  end

  def mock_mailbox_resource_id
    {"resourceId" => "1130000000000001"}
  end

  def mock_mailbox_actors
    {
      "actors" => [
        {"actorId" => "1130000000000009", "roles" => %w[shared_mailbox_reader shared_mailbox_sender]}
      ]
    }
  end

  def mock_mailbox_resources
    {
      "resources" => [
        {"resourceId" => "1130000000000001", "type" => "shared", "roles" => ["shared_mailbox_owner"]}
      ]
    }
  end

  def mock_mailbox_task
    {"taskId" => "task-42"}
  end

  def mock_mailbox_task_status
    {"status" => "complete"}
  end
end

module PasswordStubs
  def mock_domain_passwords
    {"enabled" => true, "changeFrequency" => 90}
  end
end

module DomainPolicyStubs
  def mock_domain_policies
    {
      "rules" => [
        {
          "name" => "block-spammers",
          "description" => "Reject a known bad domain",
          "enabled" => true,
          "condition" => {"domain_filter" => {"domains" => ["spam.example"]}},
          "action" => {"type" => "reject"}
        }
      ],
      "revision" => 7
    }
  end

  def mock_policy_rules
    [
      {
        "name" => "trust-partner",
        "enabled" => true,
        "condition" => {"ip_filter" => {"ips" => ["203.0.113.0/24"]}},
        "action" => {"type" => "accept", "options" => {"force" => "ham"}}
      }
    ]
  end
end

module RoutingStubs
  def mock_routing_rules
    {
      "rules" => [
        {
          "terminal" => true,
          "condition" => {"field" => "from", "operator" => "matches", "value" => "*@spam.example"},
          "actions" => [{"action" => "drop"}],
          "scope" => {"direction" => "inbound"}
        }
      ]
    }
  end
end

module ServiceApplicationStubs
  def mock_service_applications
    {
      "applications" => [
        {"id" => "app-1", "scopes" => %w[ya360_security:domain_passwords_read]}
      ]
    }
  end
end

module ExternalContactStubs
  def mock_external_contacts_list
    {
      "contacts" => [mock_external_contact],
      "page" => 1,
      "pages" => 1,
      "perPage" => 10,
      "total" => 1
    }
  end

  def mock_external_contact
    {
      "id" => "contact-1",
      "firstName" => "Ivan",
      "lastName" => "Petrov",
      "emails" => [{"email" => "ivan@partner.example", "type" => "work", "main" => true}],
      "phones" => [{"phone" => "+70000000000", "type" => "work", "main" => true}],
      "createdAt" => "2026-01-01T00:00:00Z",
      "updatedAt" => "2026-01-02T00:00:00Z"
    }
  end
end

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

  include OrganizationStubs
  include UserStubs
  include DepartmentStubs
  include GroupStubs
  include AntispamStubs
  include DomainStubs
  include DnsStubs
  include TwoFaStubs
  include AuditStubs
  include MailSettingsStubs
  include SessionStubs
  include MailboxStubs
  include PasswordStubs
  include DomainPolicyStubs
  include RoutingStubs
  include ServiceApplicationStubs
  include ExternalContactStubs
end
