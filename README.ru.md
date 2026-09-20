# Yandex 360 - Ruby API Клиент

[![Gem Version](https://badge.fury.io/rb/yandex360.svg)](https://badge.fury.io/rb/yandex360)
![Gem](https://img.shields.io/gem/dt/yandex360)
![GitHub](https://img.shields.io/github/license/ruby-api-client/yandex360)
[![Ruby specs](https://github.com/ruby-api-client/yandex360/actions/workflows/ci.yml/badge.svg)](https://github.com/ruby-api-client/yandex360/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/ruby-api-client/yandex360/badge.svg?branch=main)](https://coveralls.io/github/ruby-api-client/yandex360?branch=main)

[English](README.md) | **Русский**

Комплексная Ruby-обёртка для [Yandex 360 API](https://yandex.ru/dev/api360/), позволяющая управлять организациями, пользователями, отделами, группами, доменами, DNS-записями, настройками безопасности и многим другим.

## Содержание

- [Возможности](#возможности)
- [Требования](#требования)
- [Установка](#установка)
- [Аутентификация](#аутентификация)
- [Быстрый старт](#быстрый-старт)
- [Руководство по использованию](#руководство-по-использованию)
  - [Организации](#организации)
  - [Пользователи](#пользователи)
  - [Отделы](#отделы)
  - [Группы](#группы)
  - [Домены](#домены)
  - [DNS-записи](#dns-записи)
  - [Двухфакторная аутентификация](#двухфакторная-аутентификация-2fa)
  - [Журнал аудита](#журнал-аудита)
  - [Настройки почты](#настройки-почты)
  - [Антиспам](#антиспам)
  - [Сессии пользователей](#сессии-пользователей)
  - [Почтовые ящики](#почтовые-ящики)
  - [Парольная политика](#парольная-политика)
  - [Политики домена](#политики-домена)
  - [Маршрутизация почты](#маршрутизация-почты)
  - [Сервисные приложения](#сервисные-приложения)
  - [Внешние контакты](#внешние-контакты)
- [Обработка ошибок](#обработка-ошибок)
- [Разработка](#разработка)
- [Вклад в проект](#вклад-в-проект)
- [Лицензия](#лицензия)

## Возможности

- ✅ **Полное покрытие API** - Полная поддержка всех конечных точек Yandex 360 API
- 🔒 **OAuth аутентификация** - Безопасная аутентификация на основе токенов
- 📦 **Ресурсно-ориентированная организация** - Чистый и интуитивный интерфейс API
- 🎯 **Типобезопасность** - Структурированные объекты ответов для удобного доступа к данным
- 🔄 **Поддержка пагинации** - Встроенная обработка постраничных ответов
- 🛡️ **Обработка ошибок** - Комплексная обработка исключений для ошибок API
- 🧪 **Хорошо протестирован** - Обширное покрытие тестами с помощью RSpec

## Требования

- Ruby >= 3.3
- Faraday >= 1.7, < 3.0

## Установка

### Через Bundler

Добавьте эту строку в `Gemfile` вашего приложения:

```ruby
gem 'yandex360', '~> 1.1', '>= 1.1.4'
```

Затем выполните:

```bash
bundle install
```

### Ручная установка

```bash
gem install yandex360
```

## Аутентификация

Для использования Yandex 360 API необходим OAuth токен. Вы можете получить этот токен:

1. Зарегистрировав ваше приложение на [Yandex OAuth](https://oauth.yandex.ru/)
2. Запросив необходимые права доступа для Yandex 360 API
3. Получив access token через OAuth поток

Для дополнительной информации посетите [документацию Yandex 360 API](https://yandex.ru/dev/api360/doc/concepts/access.html).

## Быстрый старт

```ruby
require "yandex360"

# Инициализация клиента с вашим OAuth токеном
client = Yandex360::Client.new(token: "ваш_access_token")

# У таймаутов и ретраев есть значения по умолчанию, их можно настроить.
# Повторы срабатывают на 429 и 5xx, а также на ошибках соединения и таймаутах,
# и только для идемпотентных методов, поэтому POST никогда не повторяется.
client = Yandex360::Client.new(
  token: "ваш_access_token",
  open_timeout: 5,   # секунд на установку соединения
  timeout: 30,       # секунд на весь ответ
  max_retries: 2,    # попыток сверх первоначального запроса
  retry_interval: 0.5 # секунд до первого повтора, дальше удваивается
)

# Получить список всех организаций
organizations = client.organizations.list
puts "Организации: #{organizations.count}"

# Получить информацию об организации
org = client.organizations.info(org_id: 1234567)
puts "Организация: #{org.name}"

# Получить список пользователей в организации
users = client.users.list(org_id: 1234567, page: 1, per_page: 50)
users.each do |user|
  puts "Пользователь: #{user.email}"
end

# Получить домены организации
domains = client.domains.list(org_id: 1234567)
domains.each do |domain|
  puts "Домен: #{domain.name}"
end

# Проверить статус 2FA для пользователя
two_fa_status = client.two_fa.status(org_id: 1234567, user_id: 987654321)
puts "2FA включена: #{two_fa_status.enabled}"
```

## Руководство по использованию

### Организации

Управление информацией об организации и доступом.

#### Получить список всех организаций

```ruby
organizations = client.organizations.list
organizations.each do |org|
  puts "ID: #{org.id}, Название: #{org.name}"
end
```

#### Получить детальную информацию об организации

```ruby
org = client.organizations.info(org_id: 1234567)
puts "Организация: #{org.name}"
puts "Email: #{org.email}"
puts "План подписки: #{org.subscription_plan}"
```

---

### Пользователи

Комплексное управление пользователями, включая создание, обновление, псевдонимы и удаление.

#### Создать нового пользователя

```ruby
user = client.users.add(
  org_id: 1234567,
  dep_id: 1,
  nickname: "ivan.ivanov",
  password: "БезопасныйПароль123!",
  firstName: "Иван",
  lastName: "Иванов",
  gender: "male",
  position: "Разработчик",
  about: "Старший Ruby-разработчик"
)
puts "Создан пользователь: #{user.email}"
```

#### Получить список пользователей

```ruby
# Базовый список с пагинацией
users = client.users.list(org_id: 1234567, page: 1, per_page: 50)
puts "Всего пользователей: #{users.total}"
puts "Текущая страница: #{users.page}"

users.each do |user|
  puts "#{user.nickname} - #{user.email}"
end
```

#### Получить информацию о пользователе

```ruby
user = client.users.info(org_id: 1234567, user_id: 987654321)
puts "Пользователь: #{user.name.first} #{user.name.last}"
puts "Email: #{user.email}"
puts "Отдел: #{user.department_id}"
puts "Должность: #{user.position}"
```

#### Обновить информацию о пользователе

```ruby
updated_user = client.users.update(
  org_id: 1234567,
  user_id: 987654321,
  firstName: "Анна",
  position: "Ведущий разработчик"
)
puts "Обновлено: #{updated_user.email}"
```

#### Управление псевдонимами пользователя

```ruby
# Добавить псевдоним
alias_result = client.users.add_alias(
  org_id: 1234567,
  user_id: 987654321,
  user_alias: "i.ivanov"
)

# Удалить псевдоним
client.users.delete_alias(
  org_id: 1234567,
  user_id: 987654321,
  user_alias: "i.ivanov"
)
```

#### Проверить статус 2FA для пользователя

```ruby
# Получить полную информацию о 2FA
two_fa_info = client.users.get2FA(org_id: 1234567, user_id: 987654321)
puts "Есть 2FA: #{two_fa_info.has2fa}"

# Простая проверка в виде boolean
has_2fa = client.users.has2FA?(org_id: 1234567, user_id: 987654321)
puts "2FA включена: #{has_2fa}"
```

#### Удалить пользователя

```ruby
deleted_user = client.users.delete(org_id: 1234567, user_id: 987654321)
puts "Удалён: #{deleted_user.email}"
```

---

### Отделы

Организация пользователей в отделы с иерархической структурой.

#### Создать отдел

```ruby
department = client.departments.create(
  org_id: 1234567,
  name: "Разработка",
  parent_id: 1,
  description: "Отдел разработки ПО",
  label: "DEV",
  headId: 123,
  externalId: "ext-dev-001"
)
puts "Создан отдел: #{department.name}"
```

#### Получить список отделов

```ruby
departments = client.departments.list(
  org_id: 1234567,
  page: 1,
  per_page: 20,
  parent_id: 0,     # Корневые отделы
  order_by: "id"    # или "name"
)

departments.each do |dept|
  puts "Отдел: #{dept.name} (ID: #{dept.id})"
end
```

#### Получить информацию об отделе

```ruby
dept = client.departments.info(org_id: 1234567, dep_id: 5)
puts "Название: #{dept.name}"
puts "Родительский ID: #{dept.parent_id}"
puts "ID руководителя: #{dept.head_id}"
puts "Количество сотрудников: #{dept.members_count}"
```

#### Обновить отдел

```ruby
updated_dept = client.departments.update(
  org_id: 1234567,
  dep_id: 5,
  parent_id: 2,
  name: "Разработка программного обеспечения",
  description: "Обновлённое описание"
)
```

#### Управление псевдонимами отдела

```ruby
# Добавить псевдоним
alias_result = client.departments.add_alias(
  org_id: 1234567,
  dep_id: 5,
  name: "SWE"
)

# Удалить псевдоним
client.departments.delete_alias(
  org_id: 1234567,
  dep_id: 5,
  name: "SWE"
)
```

#### Удалить отдел

```ruby
client.departments.delete(org_id: 1234567, dep_id: 5)
```

---

### Группы

Создание и управление группами пользователей для лучшей организации и контроля доступа.

#### Создать группу

```ruby
group = client.groups.create(
  org_id: 1234567,
  name: "Разработчики",
  label: "dev-team",
  description: "Члены команды разработки",
  adminIds: [123, 456]
)
puts "Создана группа: #{group.name}"
```

#### Получить список групп

```ruby
groups = client.groups.list(org_id: 1234567, page: 1, per_page: 20)
groups.each do |group|
  puts "Группа: #{group.name} (#{group.members_count} участников)"
end
```

#### Получить информацию о группе

```ruby
group = client.groups.params(org_id: 1234567, group_id: 789)
puts "Название: #{group.name}"
puts "Метка: #{group.label}"
puts "Участников: #{group.members_count}"
```

#### Обновить информацию о группе

```ruby
updated_group = client.groups.update(
  org_id: 1234567,
  group_id: 789,
  name: "Старшие разработчики",
  description: "Обновлённое описание"
)
```

#### Управление участниками группы

```ruby
# Добавить пользователя в группу
result = client.groups.add_user(
  org_id: 1234567,
  group_id: 789,
  user_id: 987654321,
  type: "user"  # или "department"
)

# Получить список участников группы
members = client.groups.users(org_id: 1234567, group_id: 789)
members.each do |member|
  puts "Участник: #{member.email}"
end

# Удалить пользователя из группы
client.groups.delete_user(
  org_id: 1234567,
  group_id: 789,
  type: "user",
  user_id: 987654321
)
```

#### Удалить группу

```ruby
client.groups.delete(org_id: 1234567, group_id: 789)
```

---

### Домены

Управление доменами организации и проверка владения.

#### Получить список доменов

```ruby
domains = client.domains.list(org_id: 1234567)
domains.each do |domain|
  puts "Домен: #{domain.name}"
  puts "Статус: #{domain.status}"
  puts "Подтверждён: #{domain.verified}"
end
```

#### Добавить домен

```ruby
domain = client.domains.add(
  org_id: 1234567,
  name: "example.ru"
)
puts "Добавлен домен: #{domain.name}"
puts "Статус проверки: #{domain.status}"
```

#### Получить информацию о домене

```ruby
domain = client.domains.info(org_id: 1234567, domain: "example.ru")
puts "Домен: #{domain.name}"
puts "Статус: #{domain.status}"
puts "Подтверждён: #{domain.verified}"
puts "Email главного администратора: #{domain.master_admin}"
```

#### Подтвердить владение доменом

```ruby
domain = client.domains.verify(org_id: 1234567, domain: "example.ru")
puts "Статус проверки: #{domain.status}"
```

#### Удалить домен

```ruby
client.domains.delete(org_id: 1234567, domain: "example.ru")
```

---

### DNS-записи

Управление DNS-записями для ваших доменов напрямую через API.

#### Получить список DNS-записей

```ruby
records = client.dns.list(org_id: 1234567, domain: "example.ru")
records.each do |record|
  puts "Запись: #{record.type} #{record.name} -> #{record.data}"
  puts "TTL: #{record.ttl}"
end
```

#### Создать DNS-запись

```ruby
# A-запись
record = client.dns.create(
  org_id: 1234567,
  domain: "example.ru",
  type: "A",
  name: "www",
  data: "192.0.2.1",
  ttl: 3600
)

# MX-запись
mx_record = client.dns.create(
  org_id: 1234567,
  domain: "example.ru",
  type: "MX",
  name: "@",
  data: "mail.example.ru",
  priority: 10,
  ttl: 3600
)

# CNAME-запись
cname_record = client.dns.create(
  org_id: 1234567,
  domain: "example.ru",
  type: "CNAME",
  name: "blog",
  data: "example.github.io",
  ttl: 3600
)
```

#### Обновить DNS-запись

```ruby
updated_record = client.dns.update(
  org_id: 1234567,
  domain: "example.ru",
  record_id: 456789,
  data: "192.0.2.2",
  ttl: 7200
)
```

#### Удалить DNS-запись

```ruby
client.dns.delete(
  org_id: 1234567,
  domain: "example.ru",
  record_id: 456789
)
```

---

### Двухфакторная аутентификация (2FA)

Управление настройками двухфакторной аутентификации для пользователей и всего домена.

#### Включить 2FA для пользователя

```ruby
result = client.two_fa.enable(org_id: 1234567, user_id: 987654321)
puts "2FA успешно включена"
```

#### Отключить 2FA для пользователя

```ruby
result = client.two_fa.disable(org_id: 1234567, user_id: 987654321)
puts "2FA успешно отключена"
```

#### Проверить статус 2FA пользователя

```ruby
status = client.two_fa.status(org_id: 1234567, user_id: 987654321)
puts "2FA включена: #{status.enabled}"
puts "Есть TOTP: #{status.has_totp}"
```

#### Получить статус 2FA для всего домена

```ruby
domain_status = client.two_fa.domain_status(org_id: 1234567)
puts "2FA включена для домена: #{domain_status.enabled}"
```

#### Настроить 2FA для всего домена

```ruby
# Включить 2FA для всего домена
result = client.two_fa.configure_domain(
  org_id: 1234567,
  enabled: true
)

# Отключить 2FA для всего домена
result = client.two_fa.configure_domain(
  org_id: 1234567,
  enabled: false
)
```

---

### Журнал аудита

Доступ к журналам аудита и экспорт для отслеживания безопасности и соответствия требованиям.

#### Получить список событий аудита

```ruby
# Базовый список
events = client.audit.list(
  org_id: 1234567,
  page: 1,
  per_page: 100
)

events.each do |event|
  puts "Событие: #{event.type}"
  puts "Пользователь: #{event.user_id}"
  puts "Время: #{event.created_at}"
  puts "---"
end

# С фильтрами
filtered_events = client.audit.list(
  org_id: 1234567,
  page: 1,
  per_page: 100,
  from: "2024-01-01",
  to: "2024-12-31",
  event_type: "user.created"
)
```

#### Экспортировать журналы аудита

```ruby
# Экспорт журналов за определённый период
export_result = client.audit.export(
  org_id: 1234567,
  from: "2024-01-01",
  to: "2024-12-31",
  format: "json"  # или "csv"
)
puts "ID экспорта: #{export_result.export_id}"
```

---

### Настройки почты

Управление настройками электронной почты для пользователей, включая правила пересылки.

#### Получить настройки почты пользователя

```ruby
settings = client.post_settings.list(org_id: 1234567, user_id: 987654321)
puts "Подпись: #{settings.signature}"
puts "Ответить на: #{settings.reply_to}"
```

#### Обновить настройки почты

```ruby
updated = client.post_settings.update(
  org_id: 1234567,
  user_id: 987654321,
  signature: "С уважением,\nИван Иванов",
  replyTo: "ivan.ivanov@example.ru"
)
```

#### Управление пересылкой почты

```ruby
# Получить список адресов пересылки
forwardings = client.post_settings.forwarding_list(
  org_id: 1234567,
  user_id: 987654321
)

forwardings.each do |forwarding|
  puts "Пересылка на: #{forwarding.address}"
end

# Добавить адрес пересылки
client.post_settings.add_forwarding(
  org_id: 1234567,
  user_id: 987654321,
  address: "forward@example.ru"
)

# Удалить адрес пересылки
client.post_settings.delete_forwarding(
  org_id: 1234567,
  user_id: 987654321,
  address: "forward@example.ru"
)
```

---

### Антиспам

Управление списком разрешённых IP-адресов для защиты от спама.

#### Получить список разрешённых IP-адресов

```ruby
allowlist = client.antispam.list(org_id: 1234567)
puts "Разрешённые IP: #{allowlist.allow_list}"
```

#### Добавить IP-адреса в список разрешённых

```ruby
# Добавить один IP
result = client.antispam.create(1234567, "192.0.2.1")

# Добавить несколько IP
result = client.antispam.create(1234567, "192.0.2.1", "192.0.2.2", "192.0.2.3")

# Добавить диапазоны IP
result = client.antispam.create(1234567, "192.0.2.0/24")

puts "Обновлённый список: #{result.allow_list}"
```

#### Очистить список разрешённых IP

```ruby
client.antispam.delete(org_id: 1234567)
puts "Список очищен"
```

---

### Сессии пользователей

#### Узнать время жизни cookie сессий

```ruby
sessions = client.sessions.info(org_id: 1234567)
puts "Сессии завершаются через #{sessions.authTTL} секунд"
```

#### Задать время жизни cookie сессий

```ruby
# В секундах. Ноль означает, что сессии не истекают.
client.sessions.update(org_id: 1234567, auth_ttl: 3600)
```

#### Выйти из аккаунта на всех устройствах

```ruby
# Пригодится, когда аккаунт скомпрометирован.
client.sessions.logout(org_id: 1234567, user_id: 987654321)
```

---

### Почтовые ящики

#### Общие ящики

```ruby
mailboxes = client.mailboxes.shared_list(org_id: 1234567, page: 1, per_page: 50)
mailboxes.each {|mailbox| puts "#{mailbox.resourceId}: #{mailbox.count} сотрудников" }

created = client.mailboxes.create_shared(
  org_id: 1234567,
  email: "support@example.com",
  name: "Поддержка",
  description: "Общий ящик поддержки"
)

mailbox = client.mailboxes.shared_info(org_id: 1234567, resource_id: created.resourceId)
puts mailbox.email

client.mailboxes.update_shared(org_id: 1234567, resource_id: created.resourceId, name: "Helpdesk")
client.mailboxes.delete_shared(org_id: 1234567, resource_id: created.resourceId)
```

#### Делегированные ящики

```ruby
client.mailboxes.delegated_list(org_id: 1234567)
client.mailboxes.create_delegated(org_id: 1234567, resource_id: "1130000000000001")
client.mailboxes.delete_delegated(org_id: 1234567, resource_id: "1130000000000001")
```

#### Права доступа

```ruby
# Кто имеет доступ к ящику
client.mailboxes.actors(org_id: 1234567, resource_id: "1130000000000001")

# К каким ящикам имеет доступ сотрудник
client.mailboxes.resources(org_id: 1234567, actor_id: 987654321)

# Выдача прав асинхронная: опрашивайте статус задачи.
task = client.mailboxes.set_access(
  org_id: 1234567,
  resource_id: "1130000000000001",
  actor_id: 987654321,
  roles: ["shared_mailbox_reader", "shared_mailbox_sender"],
  notify: "none" # "all" (по умолчанию), "delegates" или "none"
)

status = client.mailboxes.task_status(org_id: 1234567, task_id: task.taskId)
puts status.status # running, complete или error
```

---

### Парольная политика

```ruby
policy = client.passwords.info(org_id: 1234567)
puts "Пользователи могут менять пароль: #{policy.enabled}"
puts "Срок действия пароля: #{policy.changeFrequency} дней"

# Каждое поле можно передавать отдельно.
client.passwords.update(org_id: 1234567, change_frequency: 90)
client.passwords.update(org_id: 1234567, enabled: false)
```

---

### Политики домена

Правила для входящей почты на уровне домена.

```ruby
policies = client.domain_policies.list(org_id: 1234567)
puts "Ревизия #{policies.revision}"
policies.rules.each {|rule| puts "#{rule.name}: #{rule.action.type}" }

# set заменяет весь набор правил: всё, что не передано, удаляется.
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

### Маршрутизация почты

```ruby
routing = client.routing.list(org_id: 1234567)
routing.rules.each {|rule| puts "#{rule.scope.direction}: #{rule.actions.first.action}" }

# set заменяет весь набор правил, как и domain_policies.set.
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

### Сервисные приложения

```ruby
apps = client.service_applications.list(org_id: 1234567)
apps.each {|app| puts "#{app.id}: #{app.scopes.join(', ')}" }

# create заменяет сохранённый список, а не дополняет его.
client.service_applications.create(
  org_id: 1234567,
  applications: [{id: "app-1", scopes: ["ya360_security:domain_passwords_read"]}]
)

client.service_applications.activate(org_id: 1234567)
client.service_applications.deactivate(org_id: 1234567)

# Удаления по одному нет: это очищает весь список.
client.service_applications.delete(org_id: 1234567)
```

---

### Внешние контакты

```ruby
contacts = client.external_contacts.list(org_id: 1234567, page: 1, per_page: 50)
contacts.each {|contact| puts "#{contact.firstName} #{contact.lastName}" }

# Нужен хотя бы один адрес.
created = client.external_contacts.create(
  org_id: 1234567,
  first_name: "Ivan",
  last_name: "Petrov",
  emails: [{email: "ivan@partner.example", type: "work", main: true}],
  company: "Partner Ltd"
)

client.external_contacts.info(org_id: 1234567, contact_id: created.id)

# PATCH: меняются только переданные поля.
client.external_contacts.update(org_id: 1234567, contact_id: created.id, title: "CTO")

# У адресов и телефонов свои эндпоинты, и каждый вызов заменяет
# весь список. Ровно один адрес должен иметь main: true.
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

## Обработка ошибок

Гем предоставляет специфичные классы исключений для различных сценариев ошибок:

```ruby
begin
  user = client.users.info(org_id: 1234567, user_id: 999999)
rescue Yandex360::AuthenticationError => e
  puts "Ошибка аутентификации: #{e.message}"
rescue Yandex360::AuthorizationError => e
  puts "Доступ запрещён: #{e.message}"
rescue Yandex360::NotFoundError => e
  puts "Ресурс не найден: #{e.message}"
rescue Yandex360::ValidationError => e
  puts "Неверные параметры: #{e.message}"
rescue Yandex360::RateLimitError => e
  puts "Превышен лимит запросов: #{e.message}"
rescue Yandex360::ServerError => e
  puts "Ошибка сервера: #{e.message}"
rescue Yandex360::Error => e
  puts "Ошибка API: #{e.message}"
end
```

### Типы исключений

- `Yandex360::Error` - Базовый класс исключений
- `Yandex360::AuthenticationError` - Неверный или отсутствующий токен (401)
- `Yandex360::AuthorizationError` - Недостаточно прав доступа (403)
- `Yandex360::NotFoundError` - Ресурс не найден (404)
- `Yandex360::ValidationError` - Неверные параметры запроса (422)
- `Yandex360::RateLimitError` - Превышен лимит запросов к API (429)
- `Yandex360::ServerError` - Ошибка на стороне сервера (5xx)

---

## Разработка

### Настройка окружения

```bash
git clone https://github.com/ruby-api-client/yandex360.git
cd yandex360
bundle install
```

### Запуск тестов

```bash
bundle exec rspec
```

### Проверка качества кода

```bash
# Запустить RuboCop
bundle exec rubocop

# Автоматическое исправление проблем
bundle exec rubocop -a
```

### Покрытие тестами

Покрытие тестами отслеживается с помощью SimpleCov и отправляется в Coveralls. После запуска тестов откройте `coverage/index.html` для просмотра отчёта о покрытии.

---

## Справочник по API

### Краткая справочная таблица

| Ресурс            | Доступные методы                                                                            |
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

### Справочник сигнатур методов

```ruby
# Организации
organizations.list()
organizations.info(org_id:)

# Пользователи
users.add(org_id:, dep_id:, **user_params)
users.add_alias(org_id:, user_id:, user_alias:)
users.update(org_id:, user_id:, **user_params)
users.info(org_id:, user_id:)
users.list(org_id:, page: 1, per_page: 10)
users.get2FA(org_id:, user_id:)
users.has2FA?(org_id:, user_id:)
users.delete_alias(org_id:, user_id:, user_alias:)
users.delete(org_id:, user_id:)

# Отделы
departments.create(org_id:, name:, parent_id:, **params)
departments.add_alias(org_id:, dep_id:, name:)
departments.update(org_id:, dep_id:, parent_id:, **params)
departments.info(org_id:, dep_id:)
departments.list(org_id:, page: 1, per_page: 10, parent_id: 0, order_by: "id")
departments.delete_alias(org_id:, dep_id:, name:)
departments.delete(org_id:, dep_id:)

# Группы
groups.create(org_id:, name:, **group_params)
groups.add_user(org_id:, group_id:, user_id:, type: "user")
groups.update(org_id:, group_id:, **user_params)
groups.params(org_id:, group_id:)
groups.list(org_id:, page: 1, per_page: 10)
groups.users(org_id:, group_id:)
groups.delete(org_id:, group_id:)
groups.delete_user(org_id:, group_id:, type:, user_id:)

# Домены
domains.list(org_id:)
domains.add(org_id:, name:, **params)
domains.info(org_id:, domain:)
domains.verify(org_id:, domain:)
domains.delete(org_id:, domain:)

# DNS-записи
dns.list(org_id:, domain:)
dns.create(org_id:, domain:, **params)
dns.update(org_id:, domain:, record_id:, **params)
dns.delete(org_id:, domain:, record_id:)

# Двухфакторная аутентификация
two_fa.enable(org_id:, user_id:)
two_fa.disable(org_id:, user_id:)
two_fa.status(org_id:, user_id:)
two_fa.domain_status(org_id:)
two_fa.configure_domain(org_id:, enabled:)

# Журнал аудита
audit.list(org_id:, page: 1, per_page: 100, **params)
audit.export(org_id:, **params)

# Настройки почты
post_settings.list(org_id:, user_id:)
post_settings.update(org_id:, user_id:, **params)
post_settings.forwarding_list(org_id:, user_id:)
post_settings.add_forwarding(org_id:, user_id:, address:)
post_settings.delete_forwarding(org_id:, user_id:, address:)

# Антиспам
antispam.list(org_id:)
antispam.create(org_id, *strings)
antispam.delete(org_id:)
```

---

## Вклад в проект

Приветствуются любые вклады! Вот как вы можете помочь:

1. Сделайте форк репозитория
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте ваши изменения (`git commit -am 'Добавить потрясающую функцию'`)
4. Отправьте изменения в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

Пожалуйста, убедитесь что:

- Все тесты проходят успешно (`bundle exec rspec`)
- Код соответствует руководству по стилю (`bundle exec rubocop`)
- Новые функции включают соответствующие тесты
- Документация обновлена по мере необходимости

## Лицензия

Этот гем доступен как открытое ПО на условиях [лицензии MIT](LICENSE).

Copyright (c) 2022 Илья Брин

## Ссылки

- [RubyGems](https://rubygems.org/gems/yandex360)
- [Документация](https://rubydoc.info/gems/yandex360)
- [Исходный код](https://github.com/ruby-api-client/yandex360)
- [Трекер задач](https://github.com/ruby-api-client/yandex360/issues)
- [Документация Yandex 360 API](https://yandex.ru/dev/api360/)

## Поддержка

Если у вас есть вопросы или нужна помощь, пожалуйста:

- Проверьте [документацию](https://rubydoc.info/gems/yandex360)
- Откройте [задачу](https://github.com/ruby-api-client/yandex360/issues)
- Обратитесь к [документации Yandex 360 API](https://yandex.ru/dev/api360/)

---

Сделано с ❤️ сообществом Ruby API Client
