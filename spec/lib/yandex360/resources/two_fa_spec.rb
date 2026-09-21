# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::TwoFaResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:path) { "/security/v1/org/#{org_id}/domain_2fa" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "#status" do
    it "reads the organization's 2FA settings" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(path) { mock_response(body: mock_domain_2fa) }

      resp = client_for(stubs).two_fa.status(org_id: org_id)

      expect(resp).to be_a(Yandex360::Domain2FA)
      expect([resp.enabled, resp.duration, resp.enabled_at])
        .to eq([true, 3600, "2026-01-01T00:00:00Z"])
    end

    it "requires org_id" do
      expect { client_for(Faraday::Adapter::Test::Stubs.new).two_fa.status(org_id: nil) }
        .to raise_error(ArgumentError, /org_id/)
    end
  end

  describe "#enable" do
    it "posts to the same path, with the grace period the API requires" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post(path) do |env|
        expect(JSON.parse(env.body)).to eq("duration" => 3600)
        mock_response(body: mock_domain_2fa)
      end

      expect(client_for(stubs).two_fa.enable(org_id: org_id, duration: 3600))
        .to be_a(Yandex360::Domain2FA)
    end

    it "sends the optional settings only when given" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post(path) do |env|
        expect(JSON.parse(env.body))
          .to eq("duration" => 60, "logoutUsers" => true, "validationMethod" => "phone")
        mock_response(body: mock_domain_2fa)
      end

      client_for(stubs).two_fa.enable(
        org_id: org_id, duration: 60, logout_users: true, validation_method: "phone"
      )
    end

    it "requires the duration, which the API does not default" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.two_fa.enable(org_id: org_id, duration: nil) }
        .to raise_error(ArgumentError, /duration/)
    end
  end

  describe "#disable" do
    it "deletes, rather than posting an enabled flag" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete(path) { mock_response(body: mock_domain_2fa.merge("enabled" => false)) }

      expect(client_for(stubs).two_fa.disable(org_id: org_id).enabled).to be(false)
    end
  end

  describe "#domain_status" do
    it "still works and says what to use" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(path) { mock_response(body: mock_domain_2fa) }
      client = client_for(stubs)

      resp = nil
      expect { resp = client.two_fa.domain_status(org_id: org_id) }
        .to output(/use two_fa\.status/).to_stderr
      expect(resp).to be_a(Yandex360::Domain2FA)
    end
  end

  describe "per-employee two-factor authentication" do
    it "is on users, not here" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect(client.users).to respond_to(:get2FA, :delete_2fa_phone)
      expect(client.two_fa).not_to respond_to(:configure_domain)
    end
  end
end
