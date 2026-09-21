# frozen_string_literal: true

require "spec_helper"

# Booted here rather than in spec_helper, so every other example still proves
# the gem works with Rails not loaded at all.
require "rails"
require "yandex360"
require "yandex360/railtie"

# Rails allows one initialize! per process: a second application raises
# FrozenError while running the engine's initializers. So the real boot happens
# once and proves the wiring end to end, and the variations are exercised
# against Yandex360::Rails, which is where that logic lives.
RSpec.describe "the Railtie" do
  before(:all) do
    Yandex360.reset_config!
    Yandex360::Instrumentation.reset!

    application = Class.new(Rails::Application) do
      config.eager_load = false
      config.logger = Logger.new(IO::NULL)
    end
    application.config.yandex360.token = "from-rails"
    application.config.yandex360.timeout = 42
    application.initialize!

    @notifications = []
    ActiveSupport::Notifications.subscribe(Yandex360::Rails::EVENT_NAME) do |*, payload|
      @notifications << payload
    end

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get("/directory/v1/org") { [200, {"Content-Type" => "application/json"}, "{}"] }
    Yandex360::Client.new(adapter: :test, stubs: stubs).organizations.list

    @config = Yandex360.config
  end

  after(:all) do
    ActiveSupport::Notifications.unsubscribe(Yandex360::Rails::EVENT_NAME)
    Yandex360.reset_config!
    Yandex360::Instrumentation.reset!
  end

  it "carries config.yandex360 into the gem" do
    expect([@config.token, @config.timeout]).to eq(["from-rails", 42])
  end

  it "leaves the gem's defaults alone where the application said nothing" do
    expect(@config.max_retries).to eq(Yandex360::Configuration::DEFAULT_MAX_RETRIES)
  end

  it "uses the Rails logger, so requests land where the application's logs do" do
    expect(@config.logger).to be(Rails.logger)
  end

  it "lets a client be built with no arguments at all" do
    expect(Yandex360::Client.new.token).to eq("from-rails")
  end

  it "republishes requests through ActiveSupport::Notifications" do
    expect(@notifications.first)
      .to include(http_method: :get, path: "/directory/v1/org", status: 200)
  end
end

RSpec.describe Yandex360::Rails do
  around do |example|
    Yandex360.reset_config!
    Yandex360::Instrumentation.reset!
    example.run
    Yandex360.reset_config!
    Yandex360::Instrumentation.reset!
  end

  describe ".apply_configuration" do
    it "copies the settings the application gave" do
      described_class.apply_configuration({token: "t", timeout: 7})

      expect([Yandex360.config.token, Yandex360.config.timeout]).to eq(["t", 7])
    end

    it "ignores settings the application left unset" do
      described_class.apply_configuration({token: "t"})

      expect(Yandex360.config.timeout).to eq(Yandex360::Configuration::DEFAULT_TIMEOUT)
    end

    it "falls back to the logger it is handed" do
      logger = Logger.new(IO::NULL)
      described_class.apply_configuration({token: "t"}, logger: logger)

      expect(Yandex360.config.logger).to be(logger)
    end

    it "prefers a logger the application named" do
      own = Logger.new(IO::NULL)
      described_class.apply_configuration({token: "t", logger: own}, logger: Logger.new(IO::NULL))

      expect(Yandex360.config.logger).to be(own)
    end
  end

  describe ".bridge_instrumentation" do
    it "instruments under the name ActiveSupport's convention produces" do
      seen = []
      notifications = double
      allow(notifications).to receive(:instrument) {|name, payload| seen << [name, payload] }
      described_class.bridge_instrumentation(notifications)

      Yandex360::Instrumentation.publish(
        Yandex360::Instrumentation::Event.new(http_method: :get, path: "/x", status: 200,
                                              duration: 0.1, error: nil)
      )

      expect(seen.first[0]).to eq("request.yandex360")
      expect(seen.first[1]).to include(path: "/x", status: 200)
    end
  end
end
