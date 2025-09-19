# frozen_string_literal: true

module Yandex360
  class Client
    BASE_URL = "https://api360.yandex.net/"

    attr_reader :token, :adapter

    def initialize(token:, adapter: Faraday.default_adapter, stubs: nil)
      raise ArgumentError, "Token cannot be nil or empty" if token.nil? || token.to_s.strip.empty?

      @token = token
      @adapter = adapter
      @stubs = stubs
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

    def organizations
      OrganizationsResource.new(self)
    end

    def domains
      DomainsResource.new(self)
    end

    def dns
      DnsResource.new(self)
    end

    def two_fa
      TwoFaResource.new(self)
    end

    def audit
      AuditResource.new(self)
    end

    def post_settings
      PostSettingsResource.new(self)
    end

    def connection
      @connection ||= build_connection
    end

    def inspect
      "#<#{self.class.name}:#{object_id} token=***>"
    end

    private

    def build_connection
      Faraday.new(BASE_URL) do |conn|
        conn.request :authorization, :OAuth, token
        conn.request :json
        conn.request :url_encoded

        conn.response :json, content_type: "application/json"

        conn.adapter adapter, @stubs
      end
    end
  end
end
