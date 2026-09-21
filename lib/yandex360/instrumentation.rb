# frozen_string_literal: true

module Yandex360
  # Reports every HTTP attempt the gem makes, without depending on any
  # framework.
  #
  #   Yandex360.on(:request) do |event|
  #     Metrics.timing("yandex360", event.duration, status: event.status)
  #   end
  #
  # Rails bridges this to ActiveSupport::Notifications under the name
  # "request.yandex360", which is the convention ActiveSupport uses
  # (event.library, as in sql.active_record). Sinatra, Hanami and a plain
  # script subscribe here directly.
  #
  # One event per HTTP attempt, not per call: a request retried twice reports
  # three times. That is what metrics should see, and it is the only way the
  # cost of retrying is visible at all.
  module Instrumentation
    # http_method rather than method: a Struct member called method would
    # override Object#method, which callers legitimately use.
    Event = Struct.new(:http_method, :path, :status, :duration, :error, keyword_init: true) do
      def success? = !error && status.to_i.between?(200, 299)
    end

    class << self
      def subscribers
        @subscribers ||= []
      end

      # Subscribing is expected at boot, before any request is made.
      def subscribe(&block)
        subscribers << block
        block
      end

      def unsubscribe(block)
        subscribers.delete(block)
      end

      def reset!
        @subscribers = []
      end

      # A subscriber must never be able to break a request: reporting is not
      # worth losing the response over.
      def publish(event)
        subscribers.each do |subscriber|
          subscriber.call(event)
        rescue StandardError => e
          warn "[yandex360] instrumentation subscriber raised #{e.class}: #{e.message}"
        end
      end
    end

    # Sits closest to the adapter so it sees each attempt separately.
    class Middleware < Faraday::Middleware
      def call(env)
        started = now
        @app.call(env).on_complete do |response_env|
          publish(env, status: response_env.status, started: started)
        end
      rescue StandardError => e
        publish(env, status: nil, started: started, error: e)
        raise
      end

      private

      def publish(env, status:, started:, error: nil)
        Instrumentation.publish(
          Event.new(
            http_method: env.method,
            path: env.url.path,
            status: status,
            duration: now - started,
            error: error
          )
        )
      end

      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    # Logging is per client rather than a global subscriber, so two clients
    # with different loggers do not end up writing into each other's.
    #
    # The token travels in a header and is never part of what is logged here.
    class Logging < Faraday::Middleware
      def initialize(app, logger)
        super(app)
        @logger = logger
      end

      def call(env)
        started = now
        method = env.method.to_s.upcase
        path = env.url.path

        @app.call(env).on_complete do |response_env|
          @logger.info { "[yandex360] #{method} #{path} #{response_env.status} #{ms_since(started)}ms" }
        end
      rescue StandardError => e
        @logger.error { "[yandex360] #{method} #{path} raised #{e.class} after #{ms_since(started)}ms" }
        raise
      end

      private

      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def ms_since(started)
        ((now - started) * 1000).round
      end
    end
  end

  class << self
    # See Yandex360::Instrumentation. Only :request is published today; the
    # argument is taken so that adding another kind later does not change how
    # this is called.
    def on(event_name, &block)
      raise ArgumentError, "Unknown event #{event_name}" unless event_name == :request

      Instrumentation.subscribe(&block)
    end
  end
end
