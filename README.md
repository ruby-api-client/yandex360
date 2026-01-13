# Yandex 360 - Ruby API Client

[![Gem Version](https://badge.fury.io/rb/yandex360.svg)](https://badge.fury.io/rb/yandex360)
![Gem](https://img.shields.io/gem/dt/yandex360)
![GitHub](https://img.shields.io/github/license/ruby-api-client/yandex360)
[![Ruby specs](https://github.com/ruby-api-client/yandex360/actions/workflows/ci.yml/badge.svg)](https://github.com/ruby-api-client/yandex360/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/ruby-api-client/yandex360/badge.svg?branch=main)](https://coveralls.io/github/ruby-api-client/yandex360?branch=main)

**English** | [Русский](README.ru.md)

A comprehensive Ruby wrapper for the [Yandex 360 API](https://yandex.ru/dev/api360/), allowing you to manage organizations, users, departments, groups, domains, DNS records, security settings, and more.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Authentication](#authentication)
- [Getting Started](#getting-started)
- [Usage Guide](#usage-guide)
  - [Organizations](#organizations)
  - [Users](#users)
  - [Departments](#departments)
  - [Groups](#groups)
  - [Domains](#domains)
  - [DNS Records](#dns-records)
  - [Two-Factor Authentication](#two-factor-authentication-2fa)
  - [Audit Logs](#audit-logs)
  - [Post Settings](#post-settings)
  - [Antispam](#antispam)
- [Error Handling](#error-handling)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Features

- ✅ **Complete API Coverage** - Full support for all Yandex 360 API endpoints
- 🔒 **OAuth Authentication** - Secure token-based authentication
- 📦 **Resource-based Organization** - Clean, intuitive API interface
- 🎯 **Type Safety** - Structured response objects for easy data access
- 🔄 **Pagination Support** - Built-in handling for paginated responses
- 🛡️ **Error Handling** - Comprehensive exception handling for API errors
- 🧪 **Well Tested** - Extensive test coverage with RSpec

## Requirements

- Ruby >= 2.6
- Faraday >= 1.7, < 3.0

## Installation

### Using Bundler

Add this line to your application's `Gemfile`:

```ruby
gem 'yandex360', '~> 1.1', '>= 1.1.4'
```

Then execute:

```bash
bundle install
```

### Manual Installation

```bash
gem install yandex360
```

## Authentication

To use the Yandex 360 API, you need an OAuth token. You can obtain this token by:

1. Registering your application at [Yandex OAuth](https://oauth.yandex.ru/)
2. Requesting the necessary scopes for Yandex 360 API access
3. Obtaining an access token through the OAuth flow

For more information, visit the [Yandex 360 API Documentation](https://yandex.ru/dev/api360/doc/concepts/access.html).

## Getting Started

```ruby
require "yandex360"

# Initialize the client with your OAuth token
client = Yandex360::Client.new(token: "your_access_token_here")

# List all organizations
organizations = client.organizations.list
puts "Organizations: #{organizations.count}"

# Get organization info
org = client.organizations.info(org_id: 1234567)
puts "Organization: #{org.name}"

# List users in an organization
users = client.users.list(org_id: 1234567, page: 1, per_page: 50)
users.each do |user|
  puts "User: #{user.email}"
end

# Get organization domains
domains = client.domains.list(org_id: 1234567)
domains.each do |domain|
  puts "Domain: #{domain.name}"
end

# Check 2FA status for a user
two_fa_status = client.two_fa.status(org_id: 1234567, user_id: 987654321)
puts "2FA enabled: #{two_fa_status.enabled}"
```

## Usage Guide

### Organizations

Manage organization information and access.

#### List all organizations

```ruby
organizations = client.organizations.list
organizations.each do |org|
  puts "ID: #{org.id}, Name: #{org.name}"
end
```

#### Get organization details

```ruby
org = client.organizations.info(org_id: 1234567)
puts "Organization: #{org.name}"
puts "Email: #{org.email}"
puts "Subscription plan: #{org.subscription_plan}"
```

---

### Users

Comprehensive user management including creation, updates, aliases, and deletion.

#### Create a new user

```ruby
user = client.users.add(
  org_id: 1234567,
  dep_id: 1,
  nickname: "john.doe",
  password: "SecurePass123!",
  firstName: "John",
  lastName: "Doe",
  gender: "male",
  position: "Developer",
  about: "Senior Ruby Developer"
)
puts "Created user: #{user.email}"
```

#### List users

```ruby
# Basic listing with pagination
users = client.users.list(org_id: 1234567, page: 1, per_page: 50)
puts "Total users: #{users.total}"
puts "Current page: #{users.page}"

users.each do |user|
  puts "#{user.nickname} - #{user.email}"
end
```

#### Get user information

```ruby
user = client.users.info(org_id: 1234567, user_id: 987654321)
puts "User: #{user.name.first} #{user.name.last}"
puts "Email: #{user.email}"
puts "Department: #{user.department_id}"
puts "Position: #{user.position}"
```

#### Update user information

```ruby
updated_user = client.users.update(
  org_id: 1234567,
  user_id: 987654321,
  firstName: "Jane",
  position: "Senior Developer"
)
puts "Updated: #{updated_user.email}"
```

#### Manage user aliases

```ruby
# Add an alias
alias_result = client.users.add_alias(
  org_id: 1234567,
  user_id: 987654321,
  user_alias: "j.doe"
)

# Delete an alias
client.users.delete_alias(
  org_id: 1234567,
  user_id: 987654321,
  user_alias: "j.doe"
)
```

#### Check 2FA status for a user

```ruby
# Get full 2FA information
two_fa_info = client.users.get2FA(org_id: 1234567, user_id: 987654321)
puts "Has 2FA: #{two_fa_info.has2fa}"

# Simple boolean check
has_2fa = client.users.has2FA?(org_id: 1234567, user_id: 987654321)
puts "2FA enabled: #{has_2fa}"
```

#### Delete a user

```ruby
deleted_user = client.users.delete(org_id: 1234567, user_id: 987654321)
puts "Deleted: #{deleted_user.email}"
```

---

### Departments

Organize users into departments with hierarchical structures.

#### Create a department

```ruby
department = client.departments.create(
  org_id: 1234567,
  name: "Engineering",
  parent_id: 1,
  description: "Software Engineering Department",
  label: "ENG",
  headId: 123,
  externalId: "ext-eng-001"
)
puts "Created department: #{department.name}"
```

#### List departments

```ruby
departments = client.departments.list(
  org_id: 1234567,
  page: 1,
  per_page: 20,
  parent_id: 0,     # Root departments
  order_by: "id"    # or "name"
)

departments.each do |dept|
  puts "Department: #{dept.name} (ID: #{dept.id})"
end
```

#### Get department information

```ruby
dept = client.departments.info(org_id: 1234567, dep_id: 5)
puts "Name: #{dept.name}"
puts "Parent ID: #{dept.parent_id}"
puts "Head ID: #{dept.head_id}"
puts "Members count: #{dept.members_count}"
```

#### Update a department

```ruby
updated_dept = client.departments.update(
  org_id: 1234567,
  dep_id: 5,
  parent_id: 2,
  name: "Software Engineering",
  description: "Updated description"
)
```

#### Manage department aliases

```ruby
# Add an alias
alias_result = client.departments.add_alias(
  org_id: 1234567,
  dep_id: 5,
  name: "SWE"
)

# Delete an alias
client.departments.delete_alias(
  org_id: 1234567,
  dep_id: 5,
  name: "SWE"
)
```

#### Delete a department

```ruby
client.departments.delete(org_id: 1234567, dep_id: 5)
```

---

### Groups

Create and manage user groups for better organization and access control.

#### Create a group

```ruby
group = client.groups.create(
  org_id: 1234567,
  name: "Developers",
  label: "dev-team",
  description: "Development team members",
  adminIds: [123, 456]
)
puts "Created group: #{group.name}"
```

#### List groups

```ruby
groups = client.groups.list(org_id: 1234567, page: 1, per_page: 20)
groups.each do |group|
  puts "Group: #{group.name} (#{group.members_count} members)"
end
```

#### Get group information

```ruby
group = client.groups.params(org_id: 1234567, group_id: 789)
puts "Name: #{group.name}"
puts "Label: #{group.label}"
puts "Members: #{group.members_count}"
```

#### Update group information

```ruby
updated_group = client.groups.update(
  org_id: 1234567,
  group_id: 789,
  name: "Senior Developers",
  description: "Updated description"
)
```

#### Manage group members

```ruby
# Add a user to a group
result = client.groups.add_user(
  org_id: 1234567,
  group_id: 789,
  user_id: 987654321,
  type: "user"  # or "department"
)

# List group members
members = client.groups.users(org_id: 1234567, group_id: 789)
members.each do |member|
  puts "Member: #{member.email}"
end

# Remove a user from a group
client.groups.delete_user(
  org_id: 1234567,
  group_id: 789,
  type: "user",
  user_id: 987654321
)
```

#### Delete a group

```ruby
client.groups.delete(org_id: 1234567, group_id: 789)
```

---

### Domains

Manage organization domains and verify ownership.

#### List domains

```ruby
domains = client.domains.list(org_id: 1234567)
domains.each do |domain|
  puts "Domain: #{domain.name}"
  puts "Status: #{domain.status}"
  puts "Verified: #{domain.verified}"
end
```

#### Add a domain

```ruby
domain = client.domains.add(
  org_id: 1234567,
  name: "example.com"
)
puts "Added domain: #{domain.name}"
puts "Verification status: #{domain.status}"
```

#### Get domain information

```ruby
domain = client.domains.info(org_id: 1234567, domain: "example.com")
puts "Domain: #{domain.name}"
puts "Status: #{domain.status}"
puts "Verified: #{domain.verified}"
puts "Master admin email: #{domain.master_admin}"
```

#### Verify domain ownership

```ruby
domain = client.domains.verify(org_id: 1234567, domain: "example.com")
puts "Verification status: #{domain.status}"
```

#### Delete a domain

```ruby
client.domains.delete(org_id: 1234567, domain: "example.com")
```

---

### DNS Records

Manage DNS records for your domains directly through the API.

#### List DNS records

```ruby
records = client.dns.list(org_id: 1234567, domain: "example.com")
records.each do |record|
  puts "Record: #{record.type} #{record.name} -> #{record.data}"
  puts "TTL: #{record.ttl}"
end
```

#### Create a DNS record

```ruby
# A Record
record = client.dns.create(
  org_id: 1234567,
  domain: "example.com",
  type: "A",
  name: "www",
  data: "192.0.2.1",
  ttl: 3600
)

# MX Record
mx_record = client.dns.create(
  org_id: 1234567,
  domain: "example.com",
  type: "MX",
  name: "@",
  data: "mail.example.com",
  priority: 10,
  ttl: 3600
)

# CNAME Record
cname_record = client.dns.create(
  org_id: 1234567,
  domain: "example.com",
  type: "CNAME",
  name: "blog",
  data: "example.github.io",
  ttl: 3600
)
```

#### Update a DNS record

```ruby
updated_record = client.dns.update(
  org_id: 1234567,
  domain: "example.com",
  record_id: 456789,
  data: "192.0.2.2",
  ttl: 7200
)
```

#### Delete a DNS record

```ruby
client.dns.delete(
  org_id: 1234567,
  domain: "example.com",
  record_id: 456789
)
```

---

### Two-Factor Authentication (2FA)

Manage two-factor authentication settings for users and the entire domain.

#### Enable 2FA for a user

```ruby
result = client.two_fa.enable(org_id: 1234567, user_id: 987654321)
puts "2FA enabled successfully"
```

#### Disable 2FA for a user

```ruby
result = client.two_fa.disable(org_id: 1234567, user_id: 987654321)
puts "2FA disabled successfully"
```

#### Check user 2FA status

```ruby
status = client.two_fa.status(org_id: 1234567, user_id: 987654321)
puts "2FA enabled: #{status.enabled}"
puts "Has TOTP: #{status.has_totp}"
```

#### Get domain-wide 2FA status

```ruby
domain_status = client.two_fa.domain_status(org_id: 1234567)
puts "Domain 2FA enabled: #{domain_status.enabled}"
```

#### Configure domain-wide 2FA

```ruby
# Enable 2FA for entire domain
result = client.two_fa.configure_domain(
  org_id: 1234567,
  enabled: true
)

# Disable 2FA for entire domain
result = client.two_fa.configure_domain(
  org_id: 1234567,
  enabled: false
)
```

---

### Audit Logs

Access and export audit logs for security and compliance tracking.

#### List audit events

```ruby
# Basic listing
events = client.audit.list(
  org_id: 1234567,
  page: 1,
  per_page: 100
)

events.each do |event|
  puts "Event: #{event.type}"
  puts "User: #{event.user_id}"
  puts "Time: #{event.created_at}"
  puts "---"
end

# With filters
filtered_events = client.audit.list(
  org_id: 1234567,
  page: 1,
  per_page: 100,
  from: "2024-01-01",
  to: "2024-12-31",
  event_type: "user.created"
)
```

#### Export audit logs

```ruby
# Export logs for a specific time range
export_result = client.audit.export(
  org_id: 1234567,
  from: "2024-01-01",
  to: "2024-12-31",
  format: "json"  # or "csv"
)
puts "Export ID: #{export_result.export_id}"
```

---

### Post Settings

Manage email settings for users including forwarding rules.

#### Get user mail settings

```ruby
settings = client.post_settings.list(org_id: 1234567, user_id: 987654321)
puts "Signature: #{settings.signature}"
puts "Reply-to: #{settings.reply_to}"
```

#### Update mail settings

```ruby
updated = client.post_settings.update(
  org_id: 1234567,
  user_id: 987654321,
  signature: "Best regards,\nJohn Doe",
  replyTo: "john.doe@example.com"
)
```

#### Manage email forwarding

```ruby
# List forwarding addresses
forwardings = client.post_settings.forwarding_list(
  org_id: 1234567,
  user_id: 987654321
)

forwardings.each do |forwarding|
  puts "Forwarding to: #{forwarding.address}"
end

# Add forwarding address
client.post_settings.add_forwarding(
  org_id: 1234567,
  user_id: 987654321,
  address: "forward@example.com"
)

# Delete forwarding address
client.post_settings.delete_forwarding(
  org_id: 1234567,
  user_id: 987654321,
  address: "forward@example.com"
)
```

---

### Antispam

Manage IP allowlist for antispam protection.

#### List allowed IPs

```ruby
allowlist = client.antispam.list(org_id: 1234567)
puts "Allowed IPs: #{allowlist.allow_list}"
```

#### Add IPs to allowlist

```ruby
# Add single IP
result = client.antispam.create(1234567, "192.0.2.1")

# Add multiple IPs
result = client.antispam.create(1234567, "192.0.2.1", "192.0.2.2", "192.0.2.3")

# Add IP ranges
result = client.antispam.create(1234567, "192.0.2.0/24")

puts "Updated allowlist: #{result.allow_list}"
```

#### Clear allowlist

```ruby
client.antispam.delete(org_id: 1234567)
puts "Allowlist cleared"
```

---

## Error Handling

The gem provides specific exception classes for different error scenarios:

```ruby
begin
  user = client.users.info(org_id: 1234567, user_id: 999999)
rescue Yandex360::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Yandex360::AuthorizationError => e
  puts "Access denied: #{e.message}"
rescue Yandex360::NotFoundError => e
  puts "Resource not found: #{e.message}"
rescue Yandex360::ValidationError => e
  puts "Invalid parameters: #{e.message}"
rescue Yandex360::RateLimitError => e
  puts "Rate limit exceeded: #{e.message}"
rescue Yandex360::ServerError => e
  puts "Server error: #{e.message}"
rescue Yandex360::Error => e
  puts "API error: #{e.message}"
end
```

### Exception Types

- `Yandex360::Error` - Base exception class
- `Yandex360::AuthenticationError` - Invalid or missing token (401)
- `Yandex360::AuthorizationError` - Insufficient permissions (403)
- `Yandex360::NotFoundError` - Resource not found (404)
- `Yandex360::ValidationError` - Invalid request parameters (422)
- `Yandex360::RateLimitError` - API rate limit exceeded (429)
- `Yandex360::ServerError` - Server-side error (5xx)

---

## Development

### Setup

```bash
git clone https://github.com/ruby-api-client/yandex360.git
cd yandex360
bundle install
```

### Running Tests

```bash
bundle exec rspec
```

### Code Quality

```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### Test Coverage

Test coverage is tracked using SimpleCov and reported to Coveralls. After running tests, open `coverage/index.html` to view the coverage report.

---

## API Reference

### Quick Reference Table

| Resource          | Available Methods                                                                           |
| ----------------- | ------------------------------------------------------------------------------------------- |
| **Organizations** | `list`, `info`                                                                              |
| **Users**         | `add`, `add_alias`, `update`, `info`, `list`, `get2FA`, `has2FA?`, `delete_alias`, `delete` |
| **Departments**   | `create`, `add_alias`, `update`, `info`, `list`, `delete_alias`, `delete`                   |
| **Groups**        | `create`, `add_user`, `update`, `params`, `list`, `users`, `delete`, `delete_user`          |
| **Domains**       | `list`, `add`, `info`, `verify`, `delete`                                                   |
| **DNS**           | `list`, `create`, `update`, `delete`                                                        |
| **Two FA**        | `enable`, `disable`, `status`, `domain_status`, `configure_domain`                          |
| **Audit**         | `list`, `export`                                                                            |
| **Post Settings** | `list`, `update`, `forwarding_list`, `add_forwarding`, `delete_forwarding`                  |
| **Antispam**      | `list`, `create`, `delete`                                                                  |

### Method Signatures Reference

```ruby
# Organizations
organizations.list()
organizations.info(org_id:)

# Users
users.add(org_id:, dep_id:, **user_params)
users.add_alias(org_id:, user_id:, user_alias:)
users.update(org_id:, user_id:, **user_params)
users.info(org_id:, user_id:)
users.list(org_id:, page: 1, per_page: 10)
users.get2FA(org_id:, user_id:)
users.has2FA?(org_id:, user_id:)
users.delete_alias(org_id:, user_id:, user_alias:)
users.delete(org_id:, user_id:)

# Departments
departments.create(org_id:, name:, parent_id:, **params)
departments.add_alias(org_id:, dep_id:, name:)
departments.update(org_id:, dep_id:, parent_id:, **params)
departments.info(org_id:, dep_id:)
departments.list(org_id:, page: 1, per_page: 10, parent_id: 0, order_by: "id")
departments.delete_alias(org_id:, dep_id:, name:)
departments.delete(org_id:, dep_id:)

# Groups
groups.create(org_id:, name:, **group_params)
groups.add_user(org_id:, group_id:, user_id:, type: "user")
groups.update(org_id:, group_id:, **user_params)
groups.params(org_id:, group_id:)
groups.list(org_id:, page: 1, per_page: 10)
groups.users(org_id:, group_id:)
groups.delete(org_id:, group_id:)
groups.delete_user(org_id:, group_id:, type:, user_id:)

# Domains
domains.list(org_id:)
domains.add(org_id:, name:, **params)
domains.info(org_id:, domain:)
domains.verify(org_id:, domain:)
domains.delete(org_id:, domain:)

# DNS Records
dns.list(org_id:, domain:)
dns.create(org_id:, domain:, **params)
dns.update(org_id:, domain:, record_id:, **params)
dns.delete(org_id:, domain:, record_id:)

# Two-Factor Authentication
two_fa.enable(org_id:, user_id:)
two_fa.disable(org_id:, user_id:)
two_fa.status(org_id:, user_id:)
two_fa.domain_status(org_id:)
two_fa.configure_domain(org_id:, enabled:)

# Audit Logs
audit.list(org_id:, page: 1, per_page: 100, **params)
audit.export(org_id:, **params)

# Post Settings
post_settings.list(org_id:, user_id:)
post_settings.update(org_id:, user_id:, **params)
post_settings.forwarding_list(org_id:, user_id:)
post_settings.add_forwarding(org_id:, user_id:, address:)
post_settings.delete_forwarding(org_id:, user_id:, address:)

# Antispam
antispam.list(org_id:)
antispam.create(org_id, *strings)
antispam.delete(org_id:)
```

---

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:

- All tests pass (`bundle exec rspec`)
- Code follows the style guide (`bundle exec rubocop`)
- New features include appropriate tests
- Documentation is updated as needed

## License

This gem is available as open source under the terms of the [MIT License](LICENSE).

Copyright (c) 2022 Ilya Brin

## Links

- [RubyGems](https://rubygems.org/gems/yandex360)
- [Documentation](https://rubydoc.info/gems/yandex360)
- [Source Code](https://github.com/ruby-api-client/yandex360)
- [Issue Tracker](https://github.com/ruby-api-client/yandex360/issues)
- [Yandex 360 API Documentation](https://yandex.ru/dev/api360/)

## Support

If you have any questions or need help, please:

- Check the [documentation](https://rubydoc.info/gems/yandex360)
- Open an [issue](https://github.com/ruby-api-client/yandex360/issues)
- Refer to the [Yandex 360 API docs](https://yandex.ru/dev/api360/)

---

Made with ❤️ by the Ruby API Client community
