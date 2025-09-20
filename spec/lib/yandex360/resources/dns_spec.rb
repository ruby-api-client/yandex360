# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#dns.list" do
  let(:org_id) { "1130000018743049" }
  let(:domain) { "example.com" }

  context "with params" do
    it "returns collection of DNS records" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/domains/#{domain}/dns") do |_env|
        mock_response(body: mock_dns_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.dns.list(org_id: org_id, domain: domain)

      expect(resp).to be_a(Yandex360::Collection)
      expect(resp.data.first).to be_a(Yandex360::DnsRecord)
    end
  end
end

RSpec.describe "#dns.create" do
  let(:org_id) { "1130000018743049" }
  let(:domain) { "example.com" }

  context "with params" do
    it "creates DNS record successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/directory/v1/org/#{org_id}/domains/#{domain}/dns") do |_env|
        mock_response(body: mock_dns_create, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.dns.create(org_id: org_id, domain: domain, type: "A", name: "test", value: "1.2.3.4")

      expect(resp).to be_a(Yandex360::DnsRecord)
    end
  end
end
