# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "Yandex360::Client connection" do
  def build_client(**opts)
    Yandex360::Client.new(token: "test_token", **opts)
  end

  describe "timeouts" do
    it "applies sane defaults so a hung call cannot pin a web thread forever" do
      options = build_client.connection.options

      expect(options.open_timeout).to eq(Yandex360::Client::DEFAULT_OPEN_TIMEOUT)
      expect(options.timeout).to eq(Yandex360::Client::DEFAULT_TIMEOUT)
    end

    it "accepts overrides" do
      options = build_client(open_timeout: 1, timeout: 2).connection.options

      expect(options.open_timeout).to eq(1)
      expect(options.timeout).to eq(2)
    end
  end

  describe "connection reuse" do
    it "builds the connection once, before any thread can race for it" do
      client = build_client

      expect(client.connection).to equal(client.connection)
    end

    it "hands the same connection to every thread" do
      client = build_client
      connections = Array.new(8) { Thread.new { client.connection } }.map(&:value)

      expect(connections.uniq.size).to eq(1)
    end
  end

  describe "retries" do
    it "registers the retry middleware" do
      handlers = build_client.connection.builder.handlers.map(&:name)

      expect(handlers).to include(a_string_matching(/Retry/))
    end

    it "retries a retryable status and succeeds" do
      attempts = 0
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") do
        attempts += 1
        attempts < 3 ? [503, {}, ""] : [200, {"Content-Type" => "application/json"}, "{}"]
      end

      client = build_client(adapter: :test, stubs: stubs, retry_interval: 0)
      client.organizations.list

      expect(attempts).to eq(3)
    end

    it "gives up after max_retries and surfaces the error" do
      attempts = 0
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") do
        attempts += 1
        [500, {}, ""]
      end

      client = build_client(adapter: :test, stubs: stubs, max_retries: 1, retry_interval: 0)

      expect { client.organizations.list }.to raise_error(Yandex360::ServerError)
      expect(attempts).to eq(2)
    end

    it "does not retry a client error, which will not change on its own" do
      attempts = 0
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") do
        attempts += 1
        [404, {}, ""]
      end

      client = build_client(adapter: :test, stubs: stubs, retry_interval: 0)

      expect { client.organizations.list }.to raise_error(Yandex360::NotFoundError)
      expect(attempts).to eq(1)
    end
  end

  describe "error mapping" do
    it "maps 503 to ServerError rather than RateLimitError" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") { [503, {}, ""] }

      client = build_client(adapter: :test, stubs: stubs, max_retries: 0)

      expect { client.organizations.list }.to raise_error(Yandex360::ServerError)
    end

    it "still maps 429 to RateLimitError" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") { [429, {}, ""] }

      client = build_client(adapter: :test, stubs: stubs, max_retries: 0)

      expect { client.organizations.list }.to raise_error(Yandex360::RateLimitError)
    end
  end
end
