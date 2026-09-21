# frozen_string_literal: true

module Yandex360
  # Field names come from the published API reference. Declared names are
  # snake_case; where the API spells a field differently, `from:` records the
  # original and keeps it working as a deprecated alias until 4.0.
  #
  # A field the API adds later needs no release here: it stays readable through
  # #[] and appears in #to_h.

  class Organization < Record
    attribute :id
    attribute :name
    attribute :email
    attribute :phone
    attribute :fax
    attribute :language
    attribute :subscription_plan, from: "subscriptionPlan"
  end

  class User < Record
    attribute :id
    attribute :nickname
    attribute :department_id, from: "departmentId"
    attribute :email
    attribute :name
    attribute :display_name, from: "displayName"
    attribute :gender
    attribute :position
    attribute :avatar_id, from: "avatarId"
    attribute :about
    attribute :birthday
    attribute :contacts
    attribute :aliases
    attribute :groups
    attribute :external_id, from: "externalId"
    attribute :is_admin, from: "isAdmin"
    attribute :is_robot, from: "isRobot"
    attribute :is_dismissed, from: "isDismissed"
    attribute :is_enabled, from: "isEnabled"
    attribute :is_enabled_updated_at, from: "isEnabledUpdatedAt"
    attribute :timezone
    attribute :language
    attribute :created_at, from: "createdAt"
    attribute :updated_at, from: "updatedAt"
  end

  class User2FA < Record
    attribute :user_id, from: "userId"
    attribute :has2fa
    attribute :has_security_phone, from: "hasSecurityPhone"
  end

  class Department < Record
    attribute :id
    attribute :name
    attribute :parent_id, from: "parentId"
    attribute :description
    attribute :label
    attribute :email
    attribute :email_id, from: "emailId"
    attribute :members_count, from: "membersCount"
    attribute :aliases
    attribute :external_id, from: "externalId"
    attribute :created_at, from: "createdAt"
  end

  class DepartmentAlias < Record
    attribute :alias
    attribute :id
    attribute :removed
  end

  class Group < Record
    attribute :id
    attribute :name
    attribute :type
    attribute :description
    attribute :members_count, from: "membersCount"
    attribute :label
    attribute :email
    attribute :email_id, from: "emailId"
    attribute :aliases
    attribute :external_id, from: "externalId"
    attribute :removed
    attribute :members
    attribute :member_of, from: "memberOf"
    attribute :created_at, from: "createdAt"
  end

  class Alias < Record
    attribute :alias
    attribute :id
    attribute :removed
  end

  class Domain < Record
    attribute :name
    attribute :country
    attribute :mx
    attribute :delegated
    attribute :master
    attribute :verified
    attribute :status
  end

  class DnsRecord < Record
    attribute :record_id, from: "recordId"
    attribute :type
    attribute :name
    attribute :ttl
    attribute :address
    attribute :target
    attribute :exchange
    attribute :preference
    attribute :text
    attribute :port
    attribute :priority
    attribute :weight
    attribute :flag
    attribute :tag
    attribute :value
  end

  class AllowList < Record
    attribute :allow_list, from: "allowList"
  end

  # Mail and Disk events share the first group of fields and then diverge.
  # Both sets are declared, so a field belonging to the other log reads as nil
  # rather than raising.
  class AuditEvent < Record
    attribute :event_type, from: "eventType"
    attribute :date
    attribute :org_id, from: "orgId"
    attribute :user_uid, from: "userUid"
    attribute :user_login, from: "userLogin"
    attribute :user_name, from: "userName"
    attribute :request_id, from: "requestId"
    attribute :uniq_id, from: "uniqId"
    attribute :client_ip, from: "clientIp"

    # Mail
    attribute :source
    attribute :actor_uid, from: "actorUid"
    attribute :mid
    attribute :dest_mid, from: "destMid"
    attribute :folder_name, from: "folderName"
    attribute :folder_type, from: "folderType"
    attribute :labels
    attribute :msg_id, from: "msgId"
    attribute :subject
    attribute :from
    attribute :to
    attribute :cc
    attribute :bcc

    # Disk
    attribute :owner_uid, from: "ownerUid"
    attribute :owner_login, from: "ownerLogin"
    attribute :owner_name, from: "ownerName"
    attribute :resource_file_id, from: "resourceFileId"
    attribute :path
    attribute :size
    attribute :last_modification_date, from: "lastModificationDate"
    attribute :rights
  end

  class DomainSession < Record
    attribute :auth_ttl, from: "authTTL"
  end

  class DomainPassword < Record
    attribute :enabled
    attribute :change_frequency, from: "changeFrequency"
  end

  class DomainPolicy < Record
    attribute :rules
    attribute :revision
  end

  class RoutingRules < Record
    attribute :rules
  end

  class ServiceApplication < Record
    attribute :id
    attribute :scopes
  end

  class ExternalContact < Record
    attribute :id
    attribute :first_name, from: "firstName"
    attribute :last_name, from: "lastName"
    attribute :middle_name, from: "middleName"
    attribute :title
    attribute :company
    attribute :department
    attribute :address
    attribute :external_id, from: "externalId"
    attribute :emails
    attribute :phones
    attribute :created_at, from: "createdAt"
    attribute :updated_at, from: "updatedAt"
  end

  class Mailbox < Record
    attribute :id
    attribute :resource_id, from: "resourceId"
    attribute :email
    attribute :name
    attribute :description
    attribute :created_at, from: "createdAt"
    attribute :updated_at, from: "updatedAt"
  end

  class MailboxResource < Record
    attribute :resource_id, from: "resourceId"
    attribute :count
    attribute :type
    attribute :roles
  end

  class MailboxActor < Record
    attribute :actor_id, from: "actorId"
    attribute :roles
  end

  class MailAddressBook < Record
    attribute :collect_addresses, from: "collectAddresses"
  end

  class MailSenderInfo < Record
    attribute :from_name, from: "fromName"
    attribute :default_from, from: "defaultFrom"
    attribute :signs
    attribute :sign_position, from: "signPosition"
  end

  class MailUserRules < Record
    attribute :autoreplies
    attribute :forwards
  end

  class MailRule < Record
    attribute :rule_id, from: "ruleId"
  end

  class MailboxTask < Record
    attribute :task_id, from: "taskId"
    attribute :status
  end
end
