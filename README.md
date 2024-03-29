# Yandex 360 - Ruby API client ([gem](https://rubygems.org/gems/yandex360))

[![Gem Version](https://badge.fury.io/rb/yandex360.svg)](https://badge.fury.io/rb/yandex360)
![Gem](https://img.shields.io/gem/dt/yandex360)
![GitHub](https://img.shields.io/github/license/ruby-api-client/yandex360)
[![Ruby specs](https://github.com/ruby-api-client/yandex360/actions/workflows/ci.yml/badge.svg)](https://github.com/ruby-api-client/yandex360/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/ruby-api-client/yandex360/badge.svg?branch=main)](https://coveralls.io/github/ruby-api-client/yandex360?branch=main)

## Installation

### Gemfile

```gemfile
gem 'yandex360', '~> 1.1', '>= 1.1.3'
```

### Install

```sh
gem install yandex360
```

## Getting started

```ruby
    require "yandex360"

    client = Yandex360::Client.new(token: "paste your access_token here")

    users = client.users.list(org_id: 1234567)
```

## Available methods

```ruby
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
