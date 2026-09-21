# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::DomainsResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:domain) { "example.com" }
  let(:base) { "/directory/v1/org/#{org_id}/domains" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "#list" do
    it "returns the domains" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(base) { mock_response(body: mock_domains_list) }

      resp = client_for(stubs).domains.list(org_id: org_id)

      expect(resp.first).to be_a(Yandex360::Domain)
      expect(resp.first.name).to eq(domain)
    end
  end

  describe "#find" do
    # The service has a list and nothing narrower, so this is a search.
    it "walks the list, since there is no endpoint for one domain" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(base) { mock_response(body: mock_domains_list) }

      expect(client_for(stubs).domains.find(org_id: org_id, domain: domain).name).to eq(domain)
    end

    it "returns nil when the name is not there" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(base) { mock_response(body: mock_domains_list) }

      expect(client_for(stubs).domains.find(org_id: org_id, domain: "absent.example")).to be_nil
    end
  end

  describe "#add" do
    it "creates one" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post(base) do |env|
        expect(JSON.parse(env.body)).to include("name" => domain)
        mock_response(body: mock_domain_added)
      end

      expect(client_for(stubs).domains.add(org_id: org_id, name: domain))
        .to be_a(Yandex360::Domain)
    end
  end

  describe "#delete" do
    it "removes one" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("#{base}/#{domain}") { mock_response(body: {}) }

      expect(client_for(stubs).domains.delete(org_id: org_id, domain: domain))
        .to be_a(Yandex360::Response)
    end
  end

  describe "#connection_status" do
    it "carries the confirmation methods and their codes" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/#{domain}/status") { mock_response(body: mock_domain_status) }

      resp = client_for(stubs).domains.connection_status(org_id: org_id, domain: domain)

      expect(resp).to be_a(Yandex360::DomainStatus)
      expect(resp.status).to eq("verified")
      expect(resp.methods.first.code).to eq("yandex-verification: abc123")
    end
  end

  describe "DKIM" do
    it "reads the status and the public key" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/#{domain}/dkim") { mock_response(body: mock_domain_dkim) }

      resp = client_for(stubs).domains.dkim_status(org_id: org_id, domain: domain)

      expect(resp).to be_a(Yandex360::DomainDkim)
      expect(resp.enabled).to be(true)
      expect(resp.public_key).to start_with("v=DKIM1")
    end

    it "enables the signature" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("#{base}/#{domain}/dkim/enable") { mock_response(body: {}) }

      expect(client_for(stubs).domains.enable_dkim(org_id: org_id, domain: domain))
        .to be_a(Yandex360::Response)
    end

    it "disables it" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("#{base}/#{domain}/dkim/disable") { mock_response(body: {}) }

      expect(client_for(stubs).domains.disable_dkim(org_id: org_id, domain: domain))
        .to be_a(Yandex360::Response)
    end
  end

  describe "what the service does not offer" do
    it "has no verify, since the API has none" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect(client.domains).not_to respond_to(:verify)
      expect(client.domains).not_to respond_to(:info)
    end
  end

  describe "validation" do
    it "requires a domain" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.domains.dkim_status(org_id: org_id, domain: nil) }
        .to raise_error(ArgumentError, /domain/)
    end
  end
end
