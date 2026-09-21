# frozen_string_literal: true

require "spec_helper"
require "yandex360"
require "logger"
require "stringio"

RSpec.describe "configuration, instrumentation and middleware" do
  around do |example|
    Yandex360.reset_config!
    Yandex360::Instrumentation.reset!
    example.run
    Yandex360.reset_config!
    Yandex360::Instrumentation.reset!
  end

  def stubs_for(status: 200, body: "{}")
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get("/directory/v1/org") { [status, {"Content-Type" => "application/json"}, body] }
    stubs
  end

  describe "Yandex360.configure" do
    it "supplies the token, so a client needs no arguments" do
      Yandex360.configure {|config| config.token = "from-config" }

      expect(Yandex360::Client.new.token).to eq("from-config")
    end

    it "supplies the other settings too" do
      Yandex360.configure do |config|
        config.token = "t"
        config.timeout = 11
        config.max_retries = 5
      end

      client = Yandex360::Client.new

      expect([client.timeout, client.max_retries]).to eq([11, 5])
    end

    it "is overridden per client" do
      Yandex360.configure {|config| config.token = "from-config" }

      client = Yandex360::Client.new(token: "explicit", timeout: 99)

      expect([client.token, client.timeout]).to eq(%w[explicit].push(99))
    end

    it "is read when the client is built and not consulted again" do
      Yandex360.configure {|config| config.token = "t" }
      client = Yandex360::Client.new

      Yandex360.configure {|config| config.timeout = 999 }

      expect(client.timeout).to eq(Yandex360::Configuration::DEFAULT_TIMEOUT)
    end

    it "still refuses to build a client with no token anywhere" do
      expect { Yandex360::Client.new }.to raise_error(ArgumentError, /Token/)
    end

    it "keeps the token out of its own inspect output" do
      Yandex360.configure {|config| config.token = "secret-token" }

      expect(Yandex360.config.inspect).to include("***")
      expect(Yandex360.config.inspect).not_to include("secret-token")
    end
  end

  describe "Yandex360.on(:request)" do
    it "reports the call" do
      events = []
      Yandex360.on(:request) {|event| events << event }

      Yandex360::Client.new(token: "t", adapter: :test, stubs: stubs_for).organizations.list

      event = events.first
      expect([event.http_method, event.path, event.status]).to eq([:get, "/directory/v1/org", 200])
      expect(event).to be_success
      expect(event.duration).to be > 0
    end

    it "reports a failed call as not successful" do
      events = []
      Yandex360.on(:request) {|event| events << event }
      client = Yandex360::Client.new(token: "t", adapter: :test, stubs: stubs_for(status: 404),
                                     max_retries: 0)

      expect { client.organizations.list }.to raise_error(Yandex360::NotFoundError)
      expect(events.first).not_to be_success
    end

    it "reports every attempt, so the cost of retrying is visible" do
      attempts = 0
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") do
        attempts += 1
        [503, {}, ""]
      end
      events = []
      Yandex360.on(:request) {|event| events << event }
      client = Yandex360::Client.new(token: "t", adapter: :test, stubs: stubs,
                                     max_retries: 2, retry_interval: 0)

      expect { client.organizations.list }.to raise_error(Yandex360::ServerError)
      expect(events.size).to eq(attempts)
    end

    it "does not let a broken subscriber break the request" do
      Yandex360.on(:request) { raise "subscriber is broken" }
      client = Yandex360::Client.new(token: "t", adapter: :test, stubs: stubs_for)

      expect { client.organizations.list }.to output(/subscriber raised/).to_stderr
    end

    it "rejects an event name it does not publish" do
      expect { Yandex360.on(:nonsense) { nil } }.to raise_error(ArgumentError, /Unknown event/)
    end
  end

  describe "logger" do
    it "logs the call without the token, which travels in a header" do
      io = StringIO.new
      client = Yandex360::Client.new(token: "secret-token", adapter: :test,
                                     stubs: stubs_for, logger: Logger.new(io))

      client.organizations.list

      expect(io.string).to include("GET /directory/v1/org 200")
      expect(io.string).not_to include("secret-token")
    end

    it "belongs to the client rather than the process" do
      quiet = StringIO.new
      loud = StringIO.new
      Yandex360::Client.new(token: "t", adapter: :test, stubs: stubs_for,
                            logger: Logger.new(loud)).organizations.list
      Yandex360::Client.new(token: "t", adapter: :test, stubs: stubs_for).organizations.list

      expect(loud.string).not_to be_empty
      expect(quiet.string).to be_empty
    end
  end

  describe "the middleware block" do
    it "runs the caller's middleware inside the stack" do
      seen = []
      spy = Class.new(Faraday::Middleware) do
        define_method(:call) do |env|
          seen << env.url.path
          @app.call(env)
        end
      end

      client = Yandex360::Client.new(token: "t", adapter: :test, stubs: stubs_for) do |conn|
        conn.use spy
      end
      client.organizations.list

      expect(seen).to eq(["/directory/v1/org"])
    end

    it "is optional" do
      client = Yandex360::Client.new(token: "t", adapter: :test, stubs: stubs_for)

      expect(client.organizations.list).to be_a(Yandex360::Collection)
    end
  end
end
