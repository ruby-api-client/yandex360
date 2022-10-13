# frozen_string_literal: true

require "addressable/uri"
require "faraday"
require "yandex360/version"

module Yandex360
  autoload :Client, "yandex360/client"
  autoload :Object, "yandex360/object"
  autoload :Resource, "yandex360/resource"
  autoload :Collection, "yandex360/collection"
  autoload :Error, "yandex360/error"

  autoload :AntispamResource, "yandex360/resources/antispam"
  autoload :AllowList, "yandex360/objects/types"

  autoload :DepartmentsResource, "yandex360/resources/departments"
  autoload :Departments, "yandex360/objects/types"
  autoload :DepartmentList, "yandex360/objects/types"
  autoload :DepartmentAlias, "yandex360/objects/types"
  autoload :DeletedDepartment, "yandex360/objects/types"
  autoload :DeletedDepartmentAlias, "yandex360/objects/types"

  autoload :GroupsResource, "yandex360/resources/groups"
  autoload :Group, "yandex360/objects/types"
  autoload :GroupList, "yandex360/objects/types"

  autoload :UsersResource, "yandex360/resources/users"
  autoload :User, "yandex360/objects/types"
end
