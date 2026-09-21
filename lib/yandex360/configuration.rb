# frozen_string_literal: true

module Yandex360
  # Defaults for every client, set once at boot.
  #
  #   Yandex360.configure do |config|
  #     config.token  = ENV.fetch("YA360_TOKEN")
  #     config.logger = Rails.logger
  #   end
  #
  # A client reads these when it is built and copies what it needs, so nothing
  # here is consulted while a request is in flight. Anything passed to
  # Yandex360::Client.new wins over what is set here.
  class Configuration
    # Seconds to wait for the connection to be established.
    DEFAULT_OPEN_TIMEOUT = 5
    # Seconds to wait for the response to complete.
    DEFAULT_TIMEOUT = 30
    # Retries attempted on top of the initial request.
    DEFAULT_MAX_RETRIES = 2
    # Seconds before the first retry. Doubles on each subsequent attempt.
    DEFAULT_RETRY_INTERVAL = 0.5

    attr_accessor :token, :adapter, :logger, :open_timeout, :timeout,
                  :max_retries, :retry_interval

    def initialize
      @token          = nil
      @adapter        = nil
      @logger         = nil
      @open_timeout   = DEFAULT_OPEN_TIMEOUT
      @timeout        = DEFAULT_TIMEOUT
      @max_retries    = DEFAULT_MAX_RETRIES
      @retry_interval = DEFAULT_RETRY_INTERVAL
    end

    SETTINGS = %i[token adapter logger open_timeout timeout max_retries retry_interval].freeze

    # A copy with the overrides applied. Anything nil is left alone, so a
    # client only has to pass what it wants to change, and the resolution
    # happens here rather than as a row of fallbacks in the constructor.
    def merge(overrides)
      copy = dup
      SETTINGS.each do |setting|
        value = overrides[setting]
        copy.public_send("#{setting}=", value) unless value.nil?
      end
      copy
    end

    # Never let a token reach a log, an error tracker or a console transcript.
    def inspect
      "#<#{self.class.name} token=#{token.nil? ? 'nil' : '***'} " \
        "timeout=#{timeout} open_timeout=#{open_timeout} " \
        "max_retries=#{max_retries} retry_interval=#{retry_interval}>"
    end
  end

  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
      config
    end

    # Mainly for tests, which need each example to start from a known state.
    def reset_config!
      @config = Configuration.new
    end
  end
end
