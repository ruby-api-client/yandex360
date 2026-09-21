# Changelog

Notable changes to this gem. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Breaking

- `two_fa` covers the organization only, and its methods have changed. Three of
  the five called paths that are not in the API:
  `/security/v1/org/{orgId}/users/{userId}/2fa/enable`, `/disable` and
  `/status` do not exist. A fourth, `configure_domain`, used the right path but
  sent `enabled`, which the endpoint does not accept.

  `Domain2FAService` puts all three operations on one path and distinguishes
  them by verb:

  | Operation | Method |
  |---|---|
  | `two_fa.status(org_id:)` | `GET /security/v1/org/{orgId}/domain_2fa` |
  | `two_fa.enable(org_id:, duration:, ...)` | `POST` to the same path |
  | `two_fa.disable(org_id:)` | `DELETE` to the same path |

  `duration` is required, since the API does not default it, and
  `logout_users` and `validation_method` are optional. `domain_status` remains
  as an alias of `status` that warns, removed in 5.0. `configure_domain` is
  gone: with enabling and disabling now separate verbs there is nothing for it
  to mean.

  Per-employee 2FA was never here. Reading it is `users.get2FA` and clearing
  the phone is `users.delete_2fa_phone`, both of which were already correct.

- `client.post_settings` is now `client.mail_settings`, and every method on it
  has changed. The old resource called paths that are not part of the API:
  `/directory/v1/org/{orgId}/users/{userId}/settings/mail` and its forwarding
  sub-paths do not exist, so none of it could have worked. The real service is
  `MailUserSettingsService`, under
  `/admin/v1/org/{orgId}/mail/users/{userId}/settings`, and it covers three
  settings rather than one:

  | Setting | Path | Methods |
  |---|---|---|
  | Contact collection | `address_book` | `address_book`, `update_address_book` |
  | Sender name and signatures | `sender_info` | `sender_info`, `update_sender_info` |
  | Auto-replies and forwards | `user_rules` | `rules`, `create_rule`, `delete_rule` |

  Forwarding is one of two kinds of rule rather than a thing of its own, so
  `forwarding_list`, `add_forwarding` and `delete_forwarding` have no
  successors of the same shape. `client.post_settings` stays as an accessor
  that warns and returns the new resource, removed in 5.0.

### Breaking

- `domains.verify` and `domains.info` are gone. `DomainService` has seven
  operations and neither is among them: there is no way to verify a domain
  through a dedicated call, and no way to read one domain. What verification
  actually needs is `domains.connection_status`, which answers the confirmation
  methods and their codes. `domains.find` replaces `info` by walking the list,
  and is named for what it does, since it costs a request per page.
- `organizations.info` now searches the list rather than fetching.
  `OrganizationsService` offers only a list, so the path it used,
  `/directory/v1/org/{orgId}`, does not exist. The method keeps its name and
  its arguments and returns nil when the token does not reach that
  organization.

### Added

- The four domain operations the gem never had: `connection_status`,
  `dkim_status`, `enable_dkim` and `disable_dkim`.

- Pagination on the three lists that have it and were missing it: `domains` and
  `dns` take `page` and `per_page`, and `organizations` pages by token, so it
  takes `page_size` and no `page`. Which list paginates and how was read from
  the reference one endpoint at a time rather than assumed, and the lists that
  answer everything at once, group members, mailbox access rights and service
  applications, are left without arguments the API would ignore. Both READMEs
  now say which is which.
- `groups.members`, answering the departments, groups and employees a group
  holds. `ListMembers` returns all three and `groups.users` shows one, so
  members of the other two kinds were invisible.

### Fixed

- `users.add_alias` returns a `User` again. `CreateUserAlias` answers the whole
  employee, aliases included, not the alias. It was changed to `Alias` in 3.0.0
  on the strength of a stub that had invented that shape, which is exactly the
  mistake the typed records were meant to expose rather than commit.
- `departments.add_alias` returns a `Department` for the same reason, and
  `departments.delete_alias` a `DepartmentAlias`, since deleting one does
  answer `{alias, removed}`.
- The stub for `groups.delete_user` said `removed`; `DeleteMember` answers
  `deleted`. `GroupService_Delete` does answer `removed`, so the two really do
  differ and the spec now asserts each correctly.

### Internal

- The Trivy scan is removed. It duplicated `bundle audit`: across 86 runs it
  reported the same five advisories in faraday and json, and dropped to zero
  the day the lockfile was refreshed. It never found anything `bundle audit`
  did not, there is no Dockerfile or infrastructure here for it to scan, and
  its findings went to the Security tab where they sat unread for months while
  the failing `bundle audit` step is what actually forced the fix. It was also
  the job that broke, failing to download its own binary. CodeQL remains the
  primary analysis, alongside bundle audit, dependency review and Dependabot.

### Notes

Every path and response shape in the gem has now been checked against the
published reference rather than against our own stubs.


## [3.2.0] - 2026-09-21

### Added

- An optional Railtie, loaded only when Rails is already present. It carries
  `config.yandex360` into the gem's configuration, uses `Rails.logger` unless
  the application names one, and republishes requests through
  `ActiveSupport::Notifications` as `request.yandex360`. Set
  `config.yandex360.instrument = false` to skip the bridge.
- A Rails section in both READMEs, which says plainly that none of it is
  required and shows the three lines that do the same thing anywhere else.

### Notes

The gem still has no Rails dependency. What the Railtie does lives in
`Yandex360::Rails` as plain methods, so it is tested without booting anything,
and the Railtie itself is wiring.

The Railtie suite runs in its own process, through `rake spec_all`. RSpec loads
every spec file into one process, so requiring rails in one of them would mean
Rails was loaded while the rest of the suite ran, and the rest of the suite is
what shows the gem works without it. Rails also permits one `initialize!` per
process, so the real boot happens once and the variations are exercised against
`Yandex360::Rails` directly.

`railties` is a development dependency, added so the Railtie is booted in a
spec rather than taken on trust, and `tzinfo-data` joins the Gemfile for
Windows, which is in the CI matrix and cannot boot Rails without it.

## [3.1.0] - 2026-09-21

Extension points, so the gem sits comfortably in Rails, Sinatra or a plain
script without depending on any of them. Nothing here is breaking.

### Added

- `Yandex360.configure` for defaults every client inherits: token, logger,
  adapter and the timeout and retry settings. Anything passed to
  `Client.new` still wins. The settings are read when a client is built and not
  consulted again, so reconfiguring later cannot change a client that already
  exists.
- A `logger:` option taking any object with the usual level methods. It logs
  verb, path, status and duration per request, and belongs to the client rather
  than the process, so two clients can log to different places. The token
  travels in a header and never reaches the log.
- `Yandex360.on(:request)`, a framework-free instrumentation hook. Events carry
  `http_method`, `path`, `status`, `duration`, `error` and `success?`. In Rails
  bridge it to `ActiveSupport::Notifications` as `request.yandex360`, the name
  ActiveSupport's own convention produces. One event per HTTP attempt rather
  than per call, so the cost of a retry is visible. A subscriber that raises is
  reported and does not break the request.
- A block on `Client.new` receiving the Faraday builder, after the gem's
  middleware and before the adapter, for middleware of your own.

### Notes

The `Client::DEFAULT_*` constants now live on `Configuration`, where the
defaults are set. They remain reachable under their old names, which were
public in 3.0.

`Client#settings` exposes the resolved configuration. 172 -> 187 examples,
line coverage stays at 100%.

## [3.0.0] - 2026-09-21

Response objects stop being OpenStruct.

### Breaking

- A misspelled attribute raises `NoMethodError` instead of returning nil.
  `user.nickame` used to be indistinguishable from a field that was genuinely
  absent.
- Attribute names are snake_case: `change_frequency`, `auth_ttl`, `first_name`,
  `event_type`. The API's own spelling still works and warns, and goes in 4.0.
  Input was already snake_case, so the two now agree.
- `Yandex360::Object` is gone, replaced by `Yandex360::Record` for declared
  types and `Yandex360::Response` for replies with no documented entity behind
  them. The old name shadowed `::Object` throughout the namespace, which meant
  any code inside `module Yandex360` needing the real one had to write
  `::Object`.
- `groups.add_user` returns a `Response` rather than a `Group`. It answers
  `{"added": true}` and never was a group; declaring fields is what exposed
  this.
- `users.add_alias` returns an `Alias` rather than a `User`, for the same
  reason.
- Eight type classes nothing constructed are removed: `UserList`, `GroupList`,
  `DepartmentList`, `UserAlias`, `DeletedUser`, `DeletedGroup`,
  `DeletedDepartment` and `DeletedDepartmentAlias`.

### Added

- `#[]` reads any key of a response, declared or not, so a field the API gains
  after a release needs no release here to be reachable. `#to_h` returns the
  parsed body as it arrived.
- Records compare by content and print their keys rather than their values.
- `groups.info`, the name the same call carries on every other resource.

### Deprecated

- `groups.params`, now an alias for `groups.info` that warns. The name said
  nothing about what the call does and collides with a very common word.
  Removed in 4.0.

### Removed

- The `ostruct` runtime dependency, which existed only for the old base class.
- `Resource#build_url`, which nothing called, and the `build_user_params`,
  `build_group_params` and `build_department_params` wrappers, each of which
  only forwarded to `build_params`. Line coverage reached 100% as a result:
  this was the code the suite could not reach.

### Internal

- Resources load by directory instead of from a hand-written list of 54
  `autoload` lines. Forgetting an entry raised `NameError` for the caller at
  runtime, and the suite caught it only if some spec happened to touch that
  constant.

### Notes

The 29 type classes were empty markers: they named a type in specs and
declared nothing, so they offered the appearance of typing without any of it.
Field lists now come from the published API reference. 152 -> 172 examples,
line coverage stays at 100%.

## [2.0.0] - 2026-09-20

Versions 1.1.5 through 1.7.0 exist in the commit history but were never
published, so this release covers everything since 1.1.4.

### Breaking

- `audit.list` and `audit.export` are gone. The resource pointed at
  `/audit/v1/org/{orgId}/events`, which is not part of the API; the audit log
  is two endpoints, `/security/v1/org/{orgId}/audit_log/mail` and
  `.../audit_log/disk`, paging by token rather than page number. Use
  `audit.mail` and `audit.disk`. (#167)
- A 503 response now raises `Yandex360::ServerError` rather than
  `Yandex360::RateLimitError`. Code rescuing `RateLimitError` to catch a 503
  must rescue `ServerError`. 429 still raises `RateLimitError`. (#160)
- `required_ruby_version` is now `>= 3.3`, matching what CI tests. It
  previously claimed `>= 2.6`, which could not have worked: faraday 2 requires
  Ruby 3.0. Existing installs are unaffected, since RubyGems keeps serving
  older releases to older Rubies. (#163)
- Passing a keyword that collides with a field a method fills in itself now
  raises `ArgumentError`. Previously one of the two values was silently
  dropped, and it was the declared one. (#168)

### Added

- Timeouts, defaulting to 5s to connect and 30s overall, and retries on 429
  and 5xx plus connection and timeout errors. Retries apply only to idempotent
  verbs, so a POST is never replayed. Both are configurable. (#160)
- Pagination on `Collection`: `page`, `pages`, `per_page`, `total`,
  `last_page?`, `next_page`, `each_page` and `auto_paginate`. `auto_paginate`
  is lazy, and the arguments of the original call carry into later pages.
  (#166, #167)
- Seven services that had no resource: `sessions`, `mailboxes`, `passwords`,
  `domain_policies`, `routing`, `service_applications` and `external_contacts`.
  All seventeen services in the API reference are now covered. (#161, #164,
  #165)
- The four remaining `UserService` operations: `delete_2fa_phone`,
  `update_avatar`, `update_contacts` and `delete_contacts`. (#168)
- `Resource#post` accepts query parameters alongside a body. (#161)

### Fixed

- `Collection#first` and `#last` raised `NameError` unconditionally, with or
  without an argument, because both referenced an undefined local instead of
  their parameter. Nine list methods return a `Collection`, so
  `client.users.list(org_id:).first` failed for every resource. (#159)
- `ostruct` is declared as a runtime dependency. It is required at runtime but
  was listed under development, so nothing guaranteed it for consumers. Ruby
  3.5 demotes it from a default gem, at which point the omission becomes a
  `LoadError`. (#159)
- `Collection#items` read a field the API never returns and so reported zero
  against the real service. It now falls back to the number of records on the
  page. (#166)
- The client built its connection on first use, which races when the client is
  shared across threads. It is built in the constructor. (#160)
- `users.get2FA` returns a `User2FA` rather than a bare `Object`. (#163)

### Changed

- The gem no longer packages the repository's own infrastructure. `s.files`
  was `git ls-files` minus `spec/`, so every release shipped `.github/` with
  all six workflows, `.gitignore`, `.rubocop.yml`, `Gemfile`, `Gemfile.lock`
  and the `Rakefile`. (#163)
- Both READMEs are reorganised: resources grouped by area, pagination and
  error handling moved ahead of the catalogue, configuration given its own
  section, and the API reference generated from the source so it cannot drift.
  (#170)

### Internal

- CI was failing on every pull request. The lockfile carried a high severity
  faraday advisory and a json one, Ruby 3.1 was past end of life and broke the
  weekly dependency job, and every action is now pinned to an exact version.
  (#158, #162)
- Releases publish to RubyGems through trusted publishing. There is no stored
  API key, nothing to rotate, and the account's MFA requirement no longer
  stands in the way of an automated release. (#171, #172)
- Tests went from 47 to 149, line coverage from 88.94% to 94.38%.

## Earlier versions

Up to and including 1.1.4 this file was generated from merged pull requests
and is kept below unchanged. Release notes for those versions are also on the
[releases page](https://github.com/ruby-api-client/yandex360/releases).

### 🧹 Maintenance

- build(deps): update faraday requirement from ~> 1.7 to >= 1.7, < 3.0 by @dependabot[bot] in #8
- build(deps-dev): update simplecov-lcov requirement from ~> 0.7.0 to ~> 0.8.0 by @dependabot[bot] in #5
- build(deps-dev): bump rspec from 3.11.0 to 3.12.0 by @dependabot[bot] in #6
- build(deps-dev): update rake requirement from ~> 12.3.3 to ~> 13.0.6 by @dependabot[bot] in #3
- build(deps): bump coverallsapp/github-action from 1.1.3 to 2.1.0 by @dependabot[bot] in #7
- build(deps): bump coverallsapp/github-action from 2.1.0 to 2.1.2 by @dependabot[bot] in #12
- build(deps): bump faraday from 2.7.4 to 2.7.5 by @dependabot[bot] in #13
- build(deps): bump coverallsapp/github-action from 2.1.2 to 2.2.0 by @dependabot[bot] in #15
- build(deps): bump faraday from 2.7.5 to 2.7.7 by @dependabot[bot] in #16
- build(deps): bump faraday from 2.7.7 to 2.7.10 by @dependabot[bot] in #19
- build(deps): bump coverallsapp/github-action from 2.2.0 to 2.2.1 by @dependabot[bot] in #20
- build(deps): bump coverallsapp/github-action from 2.2.1 to 2.2.3 by @dependabot[bot] in #25
- build(deps): bump faraday from 2.7.10 to 2.7.11 by @dependabot[bot] in #26
- build(deps): bump actions/checkout from 3 to 4 by @dependabot[bot] in #24
- build(deps-dev): bump webmock from 3.18.1 to 3.19.1 by @dependabot[bot] in #22
- build(deps-dev): update rake requirement from ~> 13.0.6 to ~> 13.1.0 by @dependabot[bot] in #27
- build(deps): bump faraday from 2.7.11 to 2.7.12 by @dependabot[bot] in #28
- build(deps-dev): bump simplecov from 0.21.2 to 0.22.0 by @dependabot[bot] in #4
- build(deps): bump faraday from 2.7.12 to 2.8.1 by @dependabot[bot] in #30
- build(deps): bump ruby/setup-ruby from 1.165.1 to 1.175.1 by @dependabot[bot] in #42
- build(deps): bump ruby/setup-ruby from 1.175.1 to 1.176.0 by @dependabot[bot] in #43
- build(deps-dev): bump rspec from 3.12.0 to 3.13.0 by @dependabot[bot] in #34
- build(deps-dev): bump webmock from 3.19.1 to 3.23.0 by @dependabot[bot] in #38
- build(deps): bump coverallsapp/github-action from 2.2.3 to 2.3.0 by @dependabot[bot] in #45
- build(deps-dev): bump rexml from 3.2.6 to 3.2.8 by @dependabot[bot] in #46
- build(deps-dev): update rake requirement from ~> 13.1.0 to ~> 13.2.1 by @dependabot[bot] in #47
- build(deps): bump ruby/setup-ruby from 1.176.0 to 1.177.0 by @dependabot[bot] in #48
- build(deps-dev): bump webmock from 3.23.0 to 3.23.1 by @dependabot[bot] in #49
- build(deps): bump ruby/setup-ruby from 1.177.0 to 1.177.1 by @dependabot[bot] in #50
- build(deps): bump ruby/setup-ruby from 1.177.1 to 1.179.0 by @dependabot[bot] in #51
- build(deps): bump ruby/setup-ruby from 1.179.0 to 1.180.1 by @dependabot[bot] in #53
- build(deps): bump ruby/setup-ruby from 1.180.1 to 1.185.0 by @dependabot[bot] in #55
- build(deps): bump ruby/setup-ruby from 1.185.0 to 1.187.0 by @dependabot[bot] in #56
- build(deps): bump ruby/setup-ruby from 1.187.0 to 1.188.0 by @dependabot[bot] in #57
- build(deps-dev): bump rexml from 3.2.8 to 3.3.2 by @dependabot[bot] in #58
- build(deps): bump ruby/setup-ruby from 1.188.0 to 1.190.0 by @dependabot[bot] in #59
- build(deps-dev): bump rexml from 3.3.2 to 3.3.6 by @dependabot[bot] in #60
- build(deps): bump ruby/setup-ruby from 1.190.0 to 1.191.0 by @dependabot[bot] in #61
- build(deps): bump ruby/setup-ruby from 1.191.0 to 1.192.0 by @dependabot[bot] in #62
- build(deps): bump ruby/setup-ruby from 1.192.0 to 1.193.0 by @dependabot[bot] in #63
- build(deps): bump ruby/setup-ruby from 1.193.0 to 1.194.0 by @dependabot[bot] in #64
- build(deps): bump ruby/setup-ruby from 1.194.0 to 1.196.0 by @dependabot[bot] in #65
- build(deps): bump ruby/setup-ruby from 1.196.0 to 1.199.0 by @dependabot[bot] in #72
- build(deps-dev): bump webmock from 3.23.1 to 3.24.0 by @dependabot[bot] in #71
- build(deps-dev): bump rexml from 3.3.6 to 3.3.9 by @dependabot[bot] in #69
- build(deps): bump coverallsapp/github-action from 2.3.0 to 2.3.4 by @dependabot[bot] in #70
- build(deps): bump ruby/setup-ruby from 1.199.0 to 1.202.0 by @dependabot[bot] in #73
- build(deps): bump ruby/setup-ruby from 1.202.0 to 1.203.0 by @dependabot[bot] in #74
- build(deps): bump ruby/setup-ruby from 1.203.0 to 1.204.0 by @dependabot[bot] in #75
- build(deps): bump ruby/setup-ruby from 1.204.0 to 1.205.0 by @dependabot[bot] in #76
- build(deps): bump ruby/setup-ruby from 1.205.0 to 1.206.0 by @dependabot[bot] in #77
- build(deps): bump ruby/setup-ruby from 1.206.0 to 1.207.0 by @dependabot[bot] in #78
- build(deps): bump ruby/setup-ruby from 1.207.0 to 1.213.0 by @dependabot[bot] in #79
- build(deps): bump coverallsapp/github-action from 2.3.4 to 2.3.6 by @dependabot[bot] in #81
- build(deps): bump ruby/setup-ruby from 1.213.0 to 1.214.0 by @dependabot[bot] in #80
- build(deps): bump ruby/setup-ruby from 1.214.0 to 1.215.0 by @dependabot[bot] in #82
- build(deps): bump ruby/setup-ruby from 1.215.0 to 1.218.0 by @dependabot[bot] in #83
- build(deps): bump ruby/setup-ruby from 1.218.0 to 1.221.0 by @dependabot[bot] in #84
- build(deps): bump ruby/setup-ruby from 1.221.0 to 1.222.0 by @dependabot[bot] in #85
- build(deps): bump ruby/setup-ruby from 1.222.0 to 1.226.0 by @dependabot[bot] in #86
- build(deps): bump ruby/setup-ruby from 1.226.0 to 1.227.0 by @dependabot[bot] in #87
- build(deps): bump ruby/setup-ruby from 1.227.0 to 1.229.0 by @dependabot[bot] in #88
- build(deps): bump ruby/setup-ruby from 1.229.0 to 1.237.0 by @dependabot[bot] in #92
- build(deps): bump ruby/setup-ruby from 1.237.0 to 1.242.0 by @dependabot[bot] in #94
- build(deps): bump ruby/setup-ruby from 1.242.0 to 1.245.0 by @dependabot[bot] in #96
- build(deps): bump ruby/setup-ruby from 1.245.0 to 1.247.0 by @dependabot[bot] in #97
- build(deps): bump actions/checkout from 4 to 5 by @dependabot[bot] in #99
- build(deps): bump ruby/setup-ruby from 1.247.0 to 1.256.0 by @dependabot[bot] in #101
- build(deps): bump ruby/setup-ruby from 1.256.0 to 1.257.0 by @dependabot[bot] in #102
- build(deps-dev): update rake requirement from ~> 13.2.1 to ~> 13.3.0 by @dependabot[bot] in #107
- build(deps-dev): bump webmock from 3.24.0 to 3.25.1 by @dependabot[bot] in #106
- build(deps-dev): bump rspec from 3.13.0 to 3.13.1 by @dependabot[bot] in #105
- build(deps-dev): update simplecov-lcov requirement from ~> 0.8.0 to ~> 0.9.0 by @dependabot[bot] in #104
- build(deps): bump ruby/setup-ruby from 1.257.0 to 1.263.0 by @dependabot[bot] in #110
- build(deps): bump ruby/setup-ruby from 1.263.0 to 1.265.0 by @dependabot[bot] in #113
- build(deps): bump github/codeql-action from 3 to 4 by @dependabot[bot] in #114
- build(deps): bump peter-evans/create-pull-request from 6 to 7 by @dependabot[bot] in #111
- build(deps): bump ruby/setup-ruby from 1.265.0 to 1.267.0 by @dependabot[bot] in #115
- build(deps): bump mikepenz/release-changelog-builder-action from 4 to 6 by @dependabot[bot] in #116
- build(deps): bump ruby/setup-ruby from 1.267.0 to 1.268.0 by @dependabot[bot] in #117
- build(deps): bump actions/checkout from 5 to 6 by @dependabot[bot] in #118
- build(deps): bump coverallsapp/github-action from 2.3.6 to 2.3.7 by @dependabot[bot] in #119
- build(deps): bump ruby/setup-ruby from 1.268.0 to 1.269.0 by @dependabot[bot] in #120
- build(deps): bump ruby/setup-ruby from 1.269.0 to 1.270.0 by @dependabot[bot] in #122
- build(deps): bump ruby/setup-ruby from 1.270.0 to 1.275.0 by @dependabot[bot] in #123
- build(deps): bump peter-evans/create-pull-request from 7 to 8 by @dependabot[bot] in #121
- build(deps): bump ruby/setup-ruby from 1.275.0 to 1.276.0 by @dependabot[bot] in #124
- build(deps): bump ruby/setup-ruby from 1.276.0 to 1.279.0 by @dependabot[bot] in #125
- build(deps): bump ruby/setup-ruby from 1.279.0 to 1.281.0 by @dependabot[bot] in #126
- build(deps): bump ruby/setup-ruby from 1.281.0 to 1.284.0 by @dependabot[bot] in #127
- build(deps): bump ruby/setup-ruby from 1.284.0 to 1.286.0 by @dependabot[bot] in #128
- build(deps): bump ruby/setup-ruby from 1.286.0 to 1.287.0 by @dependabot[bot] in #129
- build(deps): bump ruby/setup-ruby from 1.287.0 to 1.288.0 by @dependabot[bot] in #130
- build(deps): bump ruby/setup-ruby from 1.288.0 to 1.290.0 by @dependabot[bot] in #131
- build(deps): bump ruby/setup-ruby from 1.290.0 to 1.293.0 by @dependabot[bot] in #132
- build(deps): bump ruby/setup-ruby from 1.293.0 to 1.295.0 by @dependabot[bot] in #133
- build(deps): bump ruby/setup-ruby from 1.295.0 to 1.299.0 by @dependabot[bot] in #134
- build(deps): bump ruby/setup-ruby from 1.299.0 to 1.300.0 by @dependabot[bot] in #135
- build(deps): bump softprops/action-gh-release from 2 to 3 by @dependabot[bot] in #137
- build(deps): bump ruby/setup-ruby from 1.300.0 to 1.301.0 by @dependabot[bot] in #136
- build(deps): bump ruby/setup-ruby from 1.301.0 to 1.306.0 by @dependabot[bot] in #139
- build(deps): bump actions/dependency-review-action from 4 to 5 by @dependabot[bot] in #140
- build(deps): bump ruby/setup-ruby from 1.306.0 to 1.307.0 by @dependabot[bot] in #141
- build(deps): bump ruby/setup-ruby from 1.307.0 to 1.308.0 by @dependabot[bot] in #142
- build(deps): bump ruby/setup-ruby from 1.308.0 to 1.310.0 by @dependabot[bot] in #143
- build(deps): bump ruby/setup-ruby from 1.310.0 to 1.311.0 by @dependabot[bot] in #144
- build(deps): bump ruby/setup-ruby from 1.311.0 to 1.313.0 by @dependabot[bot] in #145
- build(deps): bump actions/checkout from 6 to 7 by @dependabot[bot] in #147
- build(deps): bump ruby/setup-ruby from 1.313.0 to 1.314.0 by @dependabot[bot] in #146
- build(deps): bump ruby/setup-ruby from 1.314.0 to 1.316.0 by @dependabot[bot] in #148
- build(deps): bump ruby/setup-ruby from 1.316.0 to 1.319.0 by @dependabot[bot] in #149
- build(deps): bump github/codeql-action from 4 to 4.37.4 by @dependabot[bot] in #152

[Unreleased]: https://github.com/ruby-api-client/yandex360/compare/v3.2.0...HEAD
[3.2.0]: https://github.com/ruby-api-client/yandex360/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/ruby-api-client/yandex360/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/ruby-api-client/yandex360/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/ruby-api-client/yandex360/compare/v1.1.4...v2.0.0
