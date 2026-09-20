# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::PasswordsResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:path) { "/security/v1/org/#{org_id}/domain_passwords" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "#info" do
    it "reads the password policy" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(path) { mock_response(body: mock_domain_passwords) }

      resp = client_for(stubs).passwords.info(org_id: org_id)

      expect(resp).to be_a(Yandex360::DomainPassword)
      expect(resp.enabled).to be(true)
      expect(resp.changeFrequency).to eq(90)
    end
  end

  describe "#update" do
    it "sends change_frequency as changeFrequency" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put(path) do |env|
        expect(JSON.parse(env.body)).to eq("changeFrequency" => 30)
        mock_response(body: {"enabled" => true, "changeFrequency" => 30})
      end

      expect(client_for(stubs).passwords.update(org_id: org_id, change_frequency: 30).changeFrequency)
        .to eq(30)
    end

    it "sends enabled on its own" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put(path) do |env|
        expect(JSON.parse(env.body)).to eq("enabled" => false)
        mock_response(body: {"enabled" => false, "changeFrequency" => 0})
      end

      client_for(stubs).passwords.update(org_id: org_id, enabled: false)
    end

    it "keeps a false enabled rather than dropping it as blank" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put(path) do |env|
        expect(JSON.parse(env.body)).to have_key("enabled")
        mock_response(body: {"enabled" => false, "changeFrequency" => 0})
      end

      client_for(stubs).passwords.update(org_id: org_id, enabled: false)
    end

    it "refuses an empty body, which the API rejects" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.passwords.update(org_id: org_id) }
        .to raise_error(ArgumentError, /enabled or change_frequency/)
    end
  end
end

RSpec.describe Yandex360::DomainPoliciesResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:path) { "/admin/v1/org/#{org_id}/mail/routing/policies" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "#list" do
    it "returns the rules along with the revision" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(path) { mock_response(body: mock_domain_policies) }

      resp = client_for(stubs).domain_policies.list(org_id: org_id)

      expect(resp).to be_a(Yandex360::DomainPolicy)
      expect(resp.revision).to eq(7)
      expect(resp.rules.first.name).to eq("block-spammers")
      expect(resp.rules.first.action.type).to eq("reject")
    end
  end

  describe "#set" do
    it "sends the whole rule set" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put(path) do |env|
        expect(JSON.parse(env.body)["rules"].first).to include("name" => "trust-partner")
        mock_response(body: {})
      end

      expect(client_for(stubs).domain_policies.set(org_id: org_id, rules: mock_policy_rules))
        .to be_a(Yandex360::Object)
    end

    it "requires rules" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.domain_policies.set(org_id: org_id, rules: []) }
        .to raise_error(ArgumentError, /rules/)
    end
  end
end
