# Yandex 360 - Ruby API client ([gem](https://rubygems.org/gems/yandex360))

[![Gem Version](https://badge.fury.io/rb/yandex360.svg)](https://badge.fury.io/rb/yandex360)
![Gem](https://img.shields.io/gem/dt/yandex360)
![GitHub](https://img.shields.io/github/license/ruby-api-client/yandex360)
[![Ruby specs](https://github.com/ruby-api-client/yandex360/actions/workflows/ci.yml/badge.svg)](https://github.com/ruby-api-client/yandex360/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/ruby-api-client/yandex360/badge.svg?branch=main)](https://coveralls.io/github/ruby-api-client/yandex360?branch=main)

## Installation

### Gemfile

```gemfile
gem 'yandex360', '~> 1.1', '>= 1.1.4'
```

### Install

```sh
gem install yandex360
```

## Getting started

```ruby
    require "yandex360"

    client = Yandex360::Client.new(token: "paste your access_token here")

    # List organizations
    organizations = client.organizations.list

    # List users in an organization
    users = client.users.list(org_id: 1234567)

    # Get organization domains
    domains = client.domains.list(org_id: 1234567)

    # Check 2FA status for a user
    two_fa_status = client.two_fa.status(org_id: 1234567, user_id: 987654321)
```

## Available methods

```ruby
# Organizations
organizations.list()
organizations.info(org_id:)

# Domains
domains.list(org_id:)
domains.add(org_id:, name:, **params)
domains.info(org_id:, domain:)
domains.delete(org_id:, domain:)
domains.verify(org_id:, domain:)

# DNS
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

# Audit
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
departments.add_alias(org_id:, dep_id:, name:)
departments.update(org_id:, dep_id:, parent_id:, **params)
departments.info(org_id:, dep_id:)
departments.list(org_id:, page: 1, per_page: 10, parent_id: 0, order_by: "id")
departments.create(org_id:, name:, parent_id:, **params)
departments.delete_alias(org_id:, dep_id:, name:)
departments.delete(org_id:, dep_id:)

# Groups
groups.add_user(org_id:, group_id:, user_id:, type: "user")
groups.update(org_id:, group_id:, **user_params)
groups.params(org_id:, group_id:)
groups.list(org_id:, page: 1, per_page: 10)
groups.users(org_id:, group_id:)
groups.create(org_id:, name:, **group_params)
groups.delete(org_id:, group_id:)
groups.delete_user(org_id:, group_id:, type:, user_id:)
```

## TODO

- examples
- documentation
- ~~tests~~
