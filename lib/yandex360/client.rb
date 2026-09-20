# frozen_string_literal: true

module Yandex360
  class Client
    BASE_URL = "https://api360.yandex.net/"

    # Seconds to wait for the connection to be established.
    DEFAULT_OPEN_TIMEOUT = 5
    # Seconds to wait for the response to complete.
    DEFAULT_TIMEOUT = 30
    # Retries attempted on top of the initial request.
    DEFAULT_MAX_RETRIES = 2
    # Seconds before the first retry. Doubles on each subsequent attempt.
    DEFAULT_RETRY_INTERVAL = 0.5
    # Statuses worth retrying. Everything else is a client error that will not
    # change on its own.
    RETRY_STATUSES = [429, 500, 502, 503, 504].freeze

    attr_reader :token, :adapter, :connection, :open_timeout, :timeout, :max_retries,
                :retry_interval

    def initialize(token:, adapter: Faraday.default_adapter, stubs: nil,
                   open_timeout: DEFAULT_OPEN_TIMEOUT, timeout: DEFAULT_TIMEOUT,
                   max_retries: DEFAULT_MAX_RETRIES, retry_interval: DEFAULT_RETRY_INTERVAL)
      raise ArgumentError, "Token cannot be nil or empty" if token.nil? || token.to_s.strip.empty?

      @token = token
      @adapter = adapter
      @stubs = stubs
      @open_timeout = open_timeout
      @timeout = timeout
      @max_retries = max_retries
      @retry_interval = retry_interval
      # Built eagerly: memoizing on first use races when a client is shared
      # across threads, which is the norm under Puma and Sidekiq.
      @connection = build_connection
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

    def inspect
      "#<#{self.class.name}:#{object_id} token=***>"
    end

    private

    def build_connection
      Faraday.new(BASE_URL, request: {open_timeout: open_timeout, timeout: timeout}) do |conn|
        conn.request :authorization, :OAuth, token
        conn.request :json
        conn.request :url_encoded
        conn.request :retry, retry_options

        conn.response :json, content_type: "application/json"

        conn.adapter adapter, @stubs
      end
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
