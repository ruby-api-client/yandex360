# frozen_string_literal: true

module Yandex360
  class Client
    BASE_URL = "https://api360.yandex.net/"

    # The defaults live on Configuration now, since that is where they are set.
    # They stay reachable here because they were public in 3.0.
    DEFAULT_OPEN_TIMEOUT = Configuration::DEFAULT_OPEN_TIMEOUT
    DEFAULT_TIMEOUT = Configuration::DEFAULT_TIMEOUT
    DEFAULT_MAX_RETRIES = Configuration::DEFAULT_MAX_RETRIES
    DEFAULT_RETRY_INTERVAL = Configuration::DEFAULT_RETRY_INTERVAL

    # Statuses worth retrying. Everything else is a client error that will not
    # change on its own.
    RETRY_STATUSES = [429, 500, 502, 503, 504].freeze

    attr_reader :connection, :settings

    # Anything left out falls back to Yandex360.config, which is read here and
    # not consulted again, so changing it later cannot affect a client already
    # built.
    #
    # A block is handed the Faraday builder after the gem's own middleware and
    # before the adapter, which is where your own belongs.
    #
    #   Yandex360::Client.new(token: "...") do |conn|
    #     conn.use MyTracing
    #   end
    def initialize(stubs: nil, **overrides, &middleware)
      @settings = Yandex360.config.merge(overrides)
      raise ArgumentError, "Token cannot be nil or empty" if token.nil? || token.to_s.strip.empty?

      @stubs = stubs
      @middleware = middleware
      # Built eagerly: memoizing on first use races when a client is shared
      # across threads, which is the norm under Puma and Sidekiq.
      @connection = build_connection
    end

    def token = settings.token
    def logger = settings.logger
    def open_timeout = settings.open_timeout
    def timeout = settings.timeout
    def max_retries = settings.max_retries
    def retry_interval = settings.retry_interval

    def adapter = settings.adapter || Faraday.default_adapter

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

    def mail_settings
      MailSettingsResource.new(self)
    end

    # Deprecated: the old name, for a resource that called paths the API does
    # not have. Removed in 5.0.
    def post_settings
      warn "[yandex360] client.post_settings is deprecated, use client.mail_settings", uplevel: 1
      mail_settings
    end

    def sessions
      SessionsResource.new(self)
    end

    def mailboxes
      MailboxesResource.new(self)
    end

    def passwords
      PasswordsResource.new(self)
    end

    def domain_policies
      DomainPoliciesResource.new(self)
    end

    def routing
      RoutingResource.new(self)
    end

    def service_applications
      ServiceApplicationsResource.new(self)
    end

    def external_contacts
      ExternalContactsResource.new(self)
    end

    def inspect
      "#<#{self.class.name}:#{object_id} token=***>"
    end

    private

    def build_connection
      Faraday.new(BASE_URL, request: {open_timeout: open_timeout, timeout: timeout}) do |conn|
        build_stack(conn)
        conn.adapter adapter, @stubs
      end
    end

    # Order matters here and is easier to read in one place.
    def build_stack(conn)
      conn.request :authorization, :OAuth, token
      conn.request :json
      conn.request :url_encoded
      conn.request :retry, retry_options

      conn.response :json, content_type: "application/json"

      # Inside the retry middleware, so each attempt is reported rather than
      # only the last one.
      conn.use Instrumentation::Middleware
      conn.use Instrumentation::Logging, logger if logger

      # The caller's own middleware goes last, still ahead of the adapter.
      @middleware&.call(conn)
    end

    def retry_options
      {
        max: max_retries,
        interval: retry_interval,
        backoff_factor: 2,
        retry_statuses: RETRY_STATUSES,
        # Faraday::RetriableResponse is what retry_statuses raises internally,
        # so omitting it here silently disables status-based retries.
        exceptions: [Errno::ETIMEDOUT, Timeout::Error, Faraday::TimeoutError,
                     Faraday::ConnectionFailed, Faraday::RetriableResponse]
        # `methods` is left at the faraday-retry default, which covers only
        # idempotent verbs. Replaying a POST would create duplicate records.
      }
    end
  end
end
