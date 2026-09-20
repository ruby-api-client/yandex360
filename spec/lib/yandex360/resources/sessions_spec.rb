# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::SessionsResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:user_id) { "1130000000000009" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "#info" do
    it "reads the session cookie lifetime" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/security/v1/org/#{org_id}/domain_sessions") do
        mock_response(body: mock_domain_session)
      end

      resp = client_for(stubs).sessions.info(org_id: org_id)

      expect(resp).to be_a(Yandex360::DomainSession)
      expect(resp.authTTL).to eq(86_400)
    end

    it "requires org_id" do
      expect { client_for(Faraday::Adapter::Test::Stubs.new).sessions.info(org_id: nil) }
        .to raise_error(ArgumentError, /org_id/)
    end
  end

  describe "#update" do
    it "sends auth_ttl as authTTL" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/security/v1/org/#{org_id}/domain_sessions") do |env|
        expect(JSON.parse(env.body)).to eq("authTTL" => 3600)
        mock_response(body: {"authTTL" => 3600})
      end

      resp = client_for(stubs).sessions.update(org_id: org_id, auth_ttl: 3600)

      expect(resp.authTTL).to eq(3600)
    end

    it "accepts zero, which means sessions never expire" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/security/v1/org/#{org_id}/domain_sessions") do |env|
        expect(JSON.parse(env.body)).to eq("authTTL" => 0)
        mock_response(body: {"authTTL" => 0})
      end

      expect(client_for(stubs).sessions.update(org_id: org_id, auth_ttl: 0).authTTL).to eq(0)
    end
  end

  describe "#logout" do
    it "signs the user out on all devices" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put("/security/v1/org/#{org_id}/domain_sessions/users/#{user_id}/logout") do
        mock_response(body: {})
      end

      expect(client_for(stubs).sessions.logout(org_id: org_id, user_id: user_id))
        .to be_a(Yandex360::Response)
    end

    it "requires user_id" do
      expect { client_for(Faraday::Adapter::Test::Stubs.new).sessions.logout(org_id: org_id, user_id: nil) }
        .to raise_error(ArgumentError, /user_id/)
    end
  end
end
