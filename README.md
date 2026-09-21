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
- [Upgrading from 1.x](#upgrading-from-1x)
- [Authentication](#authentication)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Choosing the HTTP library](#choosing-the-http-library)
- [Rails](#rails)
- [Pagination](#pagination)
- [Response Objects](#response-objects)
- [Error Handling](#error-handling)
- [Resources](#resources)
  - **Directory**: [Organizations](#organizations), [Users](#users), [Departments](#departments), [Groups](#groups), [External Contacts](#external-contacts)
  - **Domains**: [Domains](#domains), [DNS Records](#dns-records)
  - **Mail**: [Mail Settings](#mail-settings), [Mailboxes](#mailboxes), [Mail Routing](#mail-routing), [Domain Policies](#domain-policies), [Antispam](#antispam)
  - **Security**: [Two-Factor Authentication (2FA)](#two-factor-authentication-2fa), [User Sessions](#user-sessions), [Password Policy](#password-policy), [Audit Logs](#audit-logs), [Service Applications](#service-applications)
- [API Reference](#api-reference)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Links](#links)
- [Support](#support)

## Features

- ✅ **Complete API Coverage** - Full support for all Yandex 360 API endpoints
- 🔒 **OAuth Authentication** - Secure token-based authentication
- 📦 **Resource-based Organization** - Clean, intuitive API interface
- 🎯 **Type Safety** - Structured response objects for easy data access
- 🔄 **Pagination Support** - Built-in handling for paginated responses
- 🛡️ **Error Handling** - Comprehensive exception handling for API errors
- 🧪 **Well Tested** - Extensive test coverage with RSpec

## Requirements

- Ruby >= 3.3
- Faraday ~> 2.0

## Installation

### Using Bundler

Add this line to your application's `Gemfile`:

```ruby
gem 'yandex360', '~> 3.0'
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

## Upgrading from 1.x

Two major versions happened at once: 1.1.4 was the last published release
before 3.0.0. Everything that needs your attention is here. The
[changelog](CHANGELOG.md) has the reasoning.

### Ruby

3.0 requires Ruby 3.3. Older Rubies keep resolving to 1.1.4, so nothing
installed today breaks.

### Attribute names are snake_case

```ruby
policy.changeFrequency   # still works, warns, removed in 4.0
policy.change_frequency  # use this
```

The same applies to `auth_ttl`, `first_name`, `last_name`, `event_type`,
`resource_id`, `task_id`, `members_count` and the rest. Arguments already took
snake_case, so the two directions now agree.

### A misspelled attribute raises

```ruby
user.nickame   # was nil, now NoMethodError
```

If you relied on nil for a field that may be absent, that still works: a
declared field the response omits reads as nil. Only names the gem does not
know raise.

A field the API has gained since the last release is not a name the gem knows,
so reach for it explicitly:

```ruby
user["fieldAddedLater"]
```

### The audit log is two endpoints

`audit.list` and `audit.export` are gone. They called a path that is not part
of the API, so they could not have worked against the real service.

```ruby
client.audit.mail(org_id: 1234567, page_size: 100)
client.audit.disk(org_id: 1234567)
```

These page by token rather than page number, so there is no `page` argument.
Filters are passed in snake_case: `after_date`, `before_date`, `include_uids`.

### 503 is a server error

```ruby
begin
  client.users.list(org_id: 1234567)
rescue Yandex360::RateLimitError
  # 429 only. A 503 used to arrive here as well.
rescue Yandex360::ServerError
  # 503 arrives here now.
end
```

### Methods that returned the wrong type

Both had been wrong since they were written, and only surfaced once responses
had declared fields.

```ruby
# was a Group, is a Response, and answers {"added" => true}
client.groups.add_user(org_id: 1234567, group_id: 789, user_id: 987654321)

# was a User, is an Alias
client.users.add_alias(org_id: 1234567, user_id: 987654321, user_alias: "ivan")
```

### Renamed and removed

```ruby
# still works, warns, removed in 4.0
client.groups.params(org_id: 1234567, group_id: 789)

# use this
client.groups.info(org_id: 1234567, group_id: 789)
```

`Yandex360::Object` is now `Yandex360::Record` for declared types and
`Yandex360::Response` for replies with no documented entity behind them. Eight
type classes nothing ever constructed are gone: `UserList`, `GroupList`,
`DepartmentList`, `UserAlias`, `DeletedUser`, `DeletedGroup`,
`DeletedDepartment`, `DeletedDepartmentAlias`.

### Worth knowing, nothing to change

Requests now carry timeouts and retry 429 and 5xx on idempotent verbs, and
list results can walk their own pages. See [Configuration](#configuration) and
[Pagination](#pagination).

---

## Quick Start

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

## Configuration

The client works with the token alone. Everything below has a default and is
worth changing only when you have a reason to.

```ruby
client = Yandex360::Client.new(
  token: "your_access_token_here",
  open_timeout: 5,     # seconds to establish the connection
  timeout: 30,         # seconds for the whole response
  max_retries: 2,      # attempts on top of the initial request
  retry_interval: 0.5  # seconds before the first retry, doubling after that
)
```

Timeouts matter under a threaded web server: without them a hung call to the
API holds its thread indefinitely, which shows up as the whole application
degrading rather than one endpoint failing.

Retries cover 429 and 5xx responses along with connection and timeout errors.
They apply only to idempotent verbs, so a POST is never replayed and a retry
cannot create a second user. When the retries run out you still get the typed
error, not a Faraday one.

The client builds its connection in the constructor and is safe to share
between threads.

### Setting defaults once

```ruby
Yandex360.configure do |config|
  config.token  = ENV.fetch("YA360_TOKEN")
  config.logger = Logger.new($stdout)
end

client = Yandex360::Client.new
```

In Rails this is an initializer, in Sinatra a line at boot, in a script a call
before the work starts. No framework is required for it.

Anything passed to the constructor wins:

```ruby
Yandex360::Client.new(token: "another token", timeout: 60)
```

The settings are read when the client is built and not consulted again, so
reconfiguring later cannot change a client that already exists.

### Logging

```ruby
Yandex360::Client.new(token: "...", logger: Rails.logger)
```

Any object with the usual level methods will do. Each request is logged with
its verb, path, status and duration. The token travels in a header and never
reaches the log.

The logger belongs to the client, not the process, so two clients can log to
different places.

### Instrumentation

```ruby
Yandex360.on(:request) do |event|
  event.http_method  # :get
  event.path         # "/directory/v1/org/1234567/users"
  event.status       # 200, or nil when the request raised
  event.duration     # seconds
  event.error        # the exception, when there was one
  event.success?
end
```

This is a plain hook with no dependency on any framework. In Rails bridge it to
`ActiveSupport::Notifications` as `request.yandex360`, which is the convention
ActiveSupport follows, and your APM will pick it up:

```ruby
Yandex360.on(:request) do |event|
  ActiveSupport::Notifications.instrument("request.yandex360", event.to_h)
end
```

One event per HTTP attempt rather than per call, so a request that was retried
twice reports three times. That is what metrics should see, and it is the only
way the cost of retrying shows up at all.

A subscriber that raises is reported on stderr and does not break the request.

### Your own middleware

```ruby
client = Yandex360::Client.new(token: "...") do |conn|
  conn.use MyTracingMiddleware
  conn.request :gzip
end
```

The block is handed the Faraday builder after the gem's own middleware and
before the adapter.

---

### Choosing the HTTP library

By default the gem uses `Net::HTTP` from the standard library, so installing it
brings no HTTP stack of its own along. If that suits you, there is nothing to
configure.

Any Faraday adapter can be used instead, per client:

```ruby
Yandex360::Client.new(token: "...", adapter: :net_http)  # the default
Yandex360::Client.new(token: "...", adapter: :httpx)
Yandex360::Client.new(token: "...", adapter: :typhoeus)
```

or for every client at once:

```ruby
Yandex360.configure do |config|
  config.token = ENV.fetch("YA360_TOKEN")
  config.adapter = :httpx
end
```

Apart from `:net_http`, each adapter needs its own gem in your Gemfile, such as
`httpx` with `faraday-httpx`, or `typhoeus`. An adapter Faraday does not know
raises `Faraday::Error` when the client is built, rather than on the first
request.

This is also how you reuse a connection pool your application already has: pick
the adapter it is built on.

---

## Pagination

Every list endpoint returns one page. The collection carries the pagination
metadata and can fetch the rest on demand.

```ruby
users = client.users.list(org_id: 1234567, per_page: 100)

users.page      # current page
users.pages     # total pages
users.per_page  # page size
users.total     # total records
users.last_page?
```

Walk page by page when you want to act on each batch:

```ruby
users.each_page do |page|
  puts "Page #{page.page} of #{page.pages}: #{page.size} users"
end
```

Or iterate every record and let the pages be fetched as they are needed:

```ruby
users.auto_paginate.each {|user| puts user.nickname }

# Lazy, so this stops after the second page rather than fetching all of them.
first_fifty = client.users.list(org_id: 1234567, per_page: 25).auto_paginate.first(50)
```

Both are available on `users`, `groups`, `departments`, `external_contacts`
and the two mailbox lists. Arguments given to the original call, such as
`per_page` or a department's `parent_id`, are carried into the following pages.

## Response Objects

Every response is an object whose declared fields are real methods, so a
misspelled name says so instead of quietly handing back nil:

```ruby
user = client.users.info(org_id: 1234567, user_id: 987654321)

user.nickname    # "ivan.ivanov"
user.nickame     # NoMethodError
```

Field names are snake_case even where the API spells them otherwise, which
matches how the gem already takes its arguments:

```ruby
client.passwords.update(org_id: 1234567, change_frequency: 90)
client.passwords.info(org_id: 1234567).change_frequency
```

The original spelling still works and warns. It goes in 4.0.

```ruby
policy.changeFrequency
# [yandex360] Yandex360::DomainPassword#changeFrequency is deprecated,
# use #change_frequency
```

Nested objects and arrays of objects are wrapped too:

```ruby
user.name.first
routing.rules.first.actions.first.action
```

A field the gem does not know about, because the API gained it after the last
release, is still reachable. Nothing has to be published for you to read it:

```ruby
user["fieldAddedLater"]
user.to_h                 # the parsed body, exactly as it arrived
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
- `Yandex360::ValidationError` - Invalid request parameters (400)
- `Yandex360::RateLimitError` - API rate limit exceeded (429)
- `Yandex360::ServerError` - Server-side error (5xx)

---

## Rails

Nothing here is required. The gem has no Rails dependency, and everything the
Railtie does can be written by hand in three lines. It loads only when Rails is
already present.

Configure it where you configure everything else:

```ruby
# config/application.rb, or an initializer
config.yandex360.token = ENV.fetch("YA360_TOKEN")
config.yandex360.timeout = 60
```

Then a client needs no arguments:

```ruby
Yandex360::Client.new
```

`Rails.logger` is used unless you name a logger of your own, and requests are
published through `ActiveSupport::Notifications` as `request.yandex360`, which
is the shape ActiveSupport's own convention produces, so an APM picks them up
without being told:

```ruby
ActiveSupport::Notifications.subscribe("request.yandex360") do |*, payload|
  payload[:http_method]  # :get
  payload[:path]
  payload[:status]
  payload[:duration]
end
```

To skip the bridge:

```ruby
config.yandex360.instrument = false
```

Sinatra, Hanami, Roda or a plain script do the same thing directly, and the
result is identical:

```ruby
Yandex360.configure { |config| config.token = ENV.fetch("YA360_TOKEN") }
Yandex360.on(:request) {|event| MyMetrics.record(event) }
```

---

## Resources

Every resource hangs off the client and is grouped below by the part of
Yandex 360 it belongs to. All seventeen services in the API reference are
covered.

| Area | Accessor | Section |
|---|---|---|
| Directory | `client.organizations` | [Organizations](#organizations) |
|  | `client.users` | [Users](#users) |
|  | `client.departments` | [Departments](#departments) |
|  | `client.groups` | [Groups](#groups) |
|  | `client.external_contacts` | [External Contacts](#external-contacts) |
| Domains | `client.domains` | [Domains](#domains) |
|  | `client.dns` | [DNS Records](#dns-records) |
| Mail | `client.mail_settings` | [Mail Settings](#mail-settings) |
|  | `client.mailboxes` | [Mailboxes](#mailboxes) |
|  | `client.routing` | [Mail Routing](#mail-routing) |
|  | `client.domain_policies` | [Domain Policies](#domain-policies) |
|  | `client.antispam` | [Antispam](#antispam) |
| Security | `client.two_fa` | [Two-Factor Authentication (2FA)](#two-factor-authentication-2fa) |
|  | `client.sessions` | [User Sessions](#user-sessions) |
|  | `client.passwords` | [Password Policy](#password-policy) |
|  | `client.audit` | [Audit Logs](#audit-logs) |
|  | `client.service_applications` | [Service Applications](#service-applications) |

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

#### Avatar, contacts and the 2FA phone

```ruby
# The avatar is sent as raw bytes, not multipart or base64.
client.users.update_avatar(
  org_id: 1234567,
  user_id: 987654321,
  image: File.binread("avatar.png"),
  content_type: "image/png" # the default
)

# Replaces the contact list. Entries the API generated itself, marked
# synthetic, are not editable and survive both calls below.
client.users.update_contacts(
  org_id: 1234567,
  user_id: 987654321,
  contacts: [
    {type: "phone", value: "+70000000000", label: "Work"},
    {type: "site", value: "https://example.com"}
  ]
)

client.users.delete_contacts(org_id: 1234567, user_id: 987654321)

# Removes the phone set up for two-factor authentication. The API answers
# 400, raised here as Yandex360::ValidationError, if no phone is configured.
client.users.delete_2fa_phone(org_id: 1234567, user_id: 987654321)
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
group = client.groups.info(org_id: 1234567, group_id: 789)
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

### External Contacts

```ruby
contacts = client.external_contacts.list(org_id: 1234567, page: 1, per_page: 50)
contacts.each {|contact| puts "#{contact.first_name} #{contact.last_name}" }

# At least one email is required.
created = client.external_contacts.create(
  org_id: 1234567,
  first_name: "Ivan",
  last_name: "Petrov",
  emails: [{email: "ivan@partner.example", type: "work", main: true}],
  company: "Partner Ltd"
)

client.external_contacts.info(org_id: 1234567, contact_id: created.id)

# PATCH: only the fields given are touched.
client.external_contacts.update(org_id: 1234567, contact_id: created.id, title: "CTO")

# Emails and phones have their own endpoints, and each call replaces the
# whole list. Exactly one email must carry main: true.
client.external_contacts.update_emails(
  org_id: 1234567,
  contact_id: created.id,
  emails: [{email: "ivan@partner.example", main: true}]
)
client.external_contacts.update_phones(
  org_id: 1234567,
  contact_id: created.id,
  phones: [{phone: "+70000000000", type: "work", main: true}]
)

client.external_contacts.delete(org_id: 1234567, contact_id: created.id)
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

### Mail Settings

Per-employee settings: automatic contact collection, the sender name and
signatures, and the auto-reply and forwarding rules.

```ruby
# Automatic contact collection
book = client.mail_settings.address_book(org_id: 1234567, user_id: 987654321)
book.collect_addresses

client.mail_settings.update_address_book(
  org_id: 1234567, user_id: 987654321, collect_addresses: false
)

# Sender name, default address and signatures
info = client.mail_settings.sender_info(org_id: 1234567, user_id: 987654321)
puts "#{info.from_name} <#{info.default_from}>"
info.signs.each {|sign| puts sign.text }

client.mail_settings.update_sender_info(
  org_id: 1234567,
  user_id: 987654321,
  from_name: "Ivan Ivanov",
  sign_position: "under" # or "bottom", the default
)
```

Auto-replies and forwards are two kinds of the same rule and arrive together:

```ruby
rules = client.mail_settings.rules(org_id: 1234567, user_id: 987654321)
rules.autoreplies
rules.forwards

# One rule per call, of one kind. An auto-reply:
created = client.mail_settings.create_rule(
  org_id: 1234567, user_id: 987654321,
  rule_name: "On holiday", text: "Back on Monday"
)

# Or a forward:
client.mail_settings.create_rule(
  org_id: 1234567, user_id: 987654321,
  rule_name: "To archive", address: "archive@example.com", with_store: true
)

client.mail_settings.delete_rule(org_id: 1234567, user_id: 987654321, rule_id: created.rule_id)
```

---

### Mailboxes

#### Shared mailboxes

```ruby
mailboxes = client.mailboxes.shared_list(org_id: 1234567, page: 1, per_page: 50)
mailboxes.each {|mailbox| puts "#{mailbox.resource_id}: #{mailbox.count} employees" }

created = client.mailboxes.create_shared(
  org_id: 1234567,
  email: "support@example.com",
  name: "Support",
  description: "Shared support mailbox"
)

mailbox = client.mailboxes.shared_info(org_id: 1234567, resource_id: created.resource_id)
puts mailbox.email

client.mailboxes.update_shared(org_id: 1234567, resource_id: created.resource_id, name: "Helpdesk")
client.mailboxes.delete_shared(org_id: 1234567, resource_id: created.resource_id)
```

#### Delegated mailboxes

```ruby
client.mailboxes.delegated_list(org_id: 1234567)
client.mailboxes.create_delegated(org_id: 1234567, resource_id: "1130000000000001")
client.mailboxes.delete_delegated(org_id: 1234567, resource_id: "1130000000000001")
```

#### Access rights

```ruby
# Who can reach a mailbox
client.mailboxes.actors(org_id: 1234567, resource_id: "1130000000000001")

# Which mailboxes an employee can reach
client.mailboxes.resources(org_id: 1234567, actor_id: 987654321)

# Granting access is asynchronous: poll the returned task.
task = client.mailboxes.set_access(
  org_id: 1234567,
  resource_id: "1130000000000001",
  actor_id: 987654321,
  roles: ["shared_mailbox_reader", "shared_mailbox_sender"],
  notify: "none" # "all" (default), "delegates" or "none"
)

status = client.mailboxes.task_status(org_id: 1234567, task_id: task.task_id)
puts status.status # running, complete or error
```

---

### Mail Routing

```ruby
routing = client.routing.list(org_id: 1234567)
routing.rules.each {|rule| puts "#{rule.scope.direction}: #{rule.actions.first.action}" }

# set replaces the entire rule set, like domain_policies.set.
client.routing.set(
  org_id: 1234567,
  rules: [
    {
      terminal: true,
      scope: {direction: "inbound"},
      condition: {field: "from", operator: "matches", value: "*@spam.example"},
      actions: [{action: "drop"}]
    }
  ]
)
```

---

### Domain Policies

Rules for incoming mail at the domain level.

```ruby
policies = client.domain_policies.list(org_id: 1234567)
puts "Revision #{policies.revision}"
policies.rules.each {|rule| puts "#{rule.name}: #{rule.action.type}" }

# set replaces the entire rule set: anything left out is removed.
client.domain_policies.set(
  org_id: 1234567,
  rules: [
    {
      name: "block-spammers",
      enabled: true,
      condition: {domain_filter: {domains: ["spam.example"]}},
      action: {type: "reject"}
    },
    {
      name: "trust-partner",
      enabled: true,
      condition: {ip_filter: {ips: ["203.0.113.0/24"]}},
      action: {type: "accept", options: {force: "ham"}}
    }
  ]
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

### User Sessions

#### Read the session cookie lifetime

```ruby
sessions = client.sessions.info(org_id: 1234567)
puts "Sessions expire after #{sessions.auth_ttl} seconds"
```

#### Set the session cookie lifetime

```ruby
# Seconds. Zero means sessions never expire.
client.sessions.update(org_id: 1234567, auth_ttl: 3600)
```

#### Sign a user out on all devices

```ruby
# Useful when an account is compromised.
client.sessions.logout(org_id: 1234567, user_id: 987654321)
```

---

### Password Policy

```ruby
policy = client.passwords.info(org_id: 1234567)
puts "Users may change their password: #{policy.enabled}"
puts "Password expires after #{policy.change_frequency} days"

# Either field may be sent on its own.
client.passwords.update(org_id: 1234567, change_frequency: 90)
client.passwords.update(org_id: 1234567, enabled: false)
```

---

### Audit Logs

Mail and Disk keep separate audit logs, and they are separate endpoints. Both
page by an opaque token rather than a page number, so there is no `page`
argument here.

```ruby
# Mail events
events = client.audit.mail(org_id: 1234567, page_size: 100)

events.each do |event|
  puts "#{event.date} #{event.event_type} by #{event.user_login}"
end

# Disk events
client.audit.disk(org_id: 1234567).each {|event| puts "#{event.event_type} #{event.path}" }
```

Filters are passed as keywords in snake_case and converted to the camelCase
the API documents:

```ruby
client.audit.mail(
  org_id: 1234567,
  page_size: 100,
  after_date: "2026-01-01T00:00:00Z",
  before_date: "2026-02-01T00:00:00Z",
  include_uids: [987654321],
  types: ["message_receive", "mailbox_send"]
)
```

Pagination works as it does elsewhere, following the token the API returns:

```ruby
client.audit.mail(org_id: 1234567).each_page do |page|
  puts "#{page.size} events, more to come: #{!page.last_page?}"
end

client.audit.disk(org_id: 1234567).auto_paginate.each {|event| puts event.path }
```

`page_size` is capped at 100 by the API and defaults to that.

---

### Service Applications

```ruby
apps = client.service_applications.list(org_id: 1234567)
apps.each {|app| puts "#{app.id}: #{app.scopes.join(', ')}" }

# create replaces the stored list rather than appending to it.
client.service_applications.create(
  org_id: 1234567,
  applications: [{id: "app-1", scopes: ["ya360_security:domain_passwords_read"]}]
)

client.service_applications.activate(org_id: 1234567)
client.service_applications.deactivate(org_id: 1234567)

# There is no per-application delete: this clears the whole list.
client.service_applications.delete(org_id: 1234567)
```

---

## API Reference

Every public method, generated from the source so it cannot drift out of
date. See the sections above for what each one does.

```ruby
# Directory
organizations.list
organizations.info(org_id:)
users.add(org_id:, dep_id:, **user_params)
users.add_alias(org_id:, user_id:, user_alias:)
users.update(org_id:, user_id:, **user_params)
users.info(org_id:, user_id:)
users.list(org_id:, page: 1, per_page: 10)
users.get2FA(org_id:, user_id:)
users.has2FA?(org_id:, user_id:)
users.delete_2fa_phone(org_id:, user_id:)
users.update_avatar(org_id:, user_id:, image:, content_type: "image/png")
users.update_contacts(org_id:, user_id:, contacts:)
users.delete_contacts(org_id:, user_id:)
users.delete(org_id:, user_id:)
users.delete_alias(org_id:, user_id:, user_alias:)
departments.add_alias(org_id:, dep_id:, name:)
departments.update(org_id:, dep_id:, parent_id:, **params)
departments.info(org_id:, dep_id:)
departments.list(org_id:, page: 1, per_page: 10, parent_id: 0, order_by: "id")
departments.create(org_id:, name:, parent_id:, **params)
departments.delete_alias(org_id:, dep_id:, name:)
departments.delete(org_id:, dep_id:)
groups.add_user(org_id:, group_id:, user_id:, type: "user")
groups.update(org_id:, group_id:, **user_params)
groups.info(org_id:, group_id:)
groups.params(org_id:, group_id:)   # deprecated, use info
groups.list(org_id:, page: 1, per_page: 10)
groups.users(org_id:, group_id:)
groups.create(org_id:, name:, **group_params)
groups.delete(org_id:, group_id:)
groups.delete_user(org_id:, group_id:, type:, user_id:)
external_contacts.list(org_id:, page: 1, per_page: 10)
external_contacts.create(org_id:, first_name:, last_name:, emails:, **params)
external_contacts.info(org_id:, contact_id:)
external_contacts.update(org_id:, contact_id:, **params)
external_contacts.delete(org_id:, contact_id:)
external_contacts.update_emails(org_id:, contact_id:, emails:)
external_contacts.update_phones(org_id:, contact_id:, phones:)

# Domains
domains.list(org_id:)
domains.add(org_id:, name:, **params)
domains.info(org_id:, domain:)
domains.delete(org_id:, domain:)
domains.verify(org_id:, domain:)
dns.list(org_id:, domain:)
dns.create(org_id:, domain:, **params)
dns.update(org_id:, domain:, record_id:, **params)
dns.delete(org_id:, domain:, record_id:)

# Mail
mail_settings.address_book(org_id:, user_id:)
mail_settings.update_address_book(org_id:, user_id:, collect_addresses:)
mail_settings.sender_info(org_id:, user_id:)
mail_settings.update_sender_info(org_id:, user_id:, **params)
mail_settings.rules(org_id:, user_id:)
mail_settings.create_rule(org_id:, user_id:, **params)
mail_settings.delete_rule(org_id:, user_id:, rule_id:)
mailboxes.shared_list(org_id:, page: 1, per_page: 10)
mailboxes.create_shared(org_id:, email:, name:, description:)
mailboxes.shared_info(org_id:, resource_id:)
mailboxes.update_shared(org_id:, resource_id:, **params)
mailboxes.delete_shared(org_id:, resource_id:)
mailboxes.delegated_list(org_id:, page: 1, per_page: 10)
mailboxes.create_delegated(org_id:, resource_id:)
mailboxes.delete_delegated(org_id:, resource_id:)
mailboxes.actors(org_id:, resource_id:)
mailboxes.resources(org_id:, actor_id:)
mailboxes.set_access(org_id:, resource_id:, actor_id:, roles:, notify: nil)
mailboxes.task_status(org_id:, task_id:)
routing.list(org_id:)
routing.set(org_id:, rules:)
domain_policies.list(org_id:)
domain_policies.set(org_id:, rules:)
antispam.list(org_id:)
antispam.create(org_id, *strings)
antispam.delete(org_id:)

# Security
two_fa.enable(org_id:, user_id:)
two_fa.disable(org_id:, user_id:)
two_fa.status(org_id:, user_id:)
two_fa.domain_status(org_id:)
two_fa.configure_domain(org_id:, enabled:)
sessions.info(org_id:)
sessions.update(org_id:, auth_ttl:)
sessions.logout(org_id:, user_id:)
passwords.info(org_id:)
passwords.update(org_id:, enabled: nil, change_frequency: nil)
audit.mail(org_id:, page_size: 100, page_token: nil, **filters)
audit.disk(org_id:, page_size: 100, page_token: nil, **filters)
service_applications.list(org_id:)
service_applications.create(org_id:, applications:)
service_applications.delete(org_id:)
service_applications.activate(org_id:)
service_applications.deactivate(org_id:)
```

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
