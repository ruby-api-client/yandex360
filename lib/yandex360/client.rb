# frozen_string_literal: true

module Yandex360
  class Client
    BASE_URL = "https://api360.yandex.net/"

    attr_reader :token, :adapter

    # new client
    def initialize(token:, adapter: Faraday.default_adapter, stubs: nil)
      @token = token
      @adapter = adapter
      @stubs = stubs # Test stubs for requests
    end

    def antispam
      AntispamResource.new(self)
    end

    def departments
      DepartmentsResource.new(self)
    end

    def groups
      GroupsResource.new(self)
    end

    def users
      UsersResource.new(self)
    end

    def orgs
      OrganizationResource.new(self)
    end

    def connection
      @connection ||= Faraday.new(BASE_URL) do |conn|
        conn.request :authorization, :OAuth, token
        conn.request :json
        conn.request :url_encoded

        conn.response :json, content_type: "application/json"

        conn.adapter adapter, @stubs
      end
    end
  end
end
