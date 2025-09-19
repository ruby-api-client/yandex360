# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#domains.list" do
  let(:org_id) { "1130000018743049" }

  context "with params" do
    it "returns collection of domains" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/domains") do |env|
        mock_response(body: mock_domains_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.domains.list(org_id: org_id)

      expect(resp).to be_a(Yandex360::Collection)
      expect(resp.data.first).to be_a(Yandex360::Domain)
    end
  end
end

RSpec.describe "#domains.info" do
  let(:org_id) { "1130000018743049" }
  let(:domain) { "example.com" }

  context "with params" do
    it "gets domain info successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/domains/#{domain}") do |env|
        mock_response(body: mock_domain_info)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.domains.info(org_id: org_id, domain: domain)

      expect(resp).to be_a(Yandex360::Domain)
    end
  end
end

RSpec.describe "#domains.add" do
  let(:org_id) { "1130000018743049" }
  let(:domain_name) { "newdomain.com" }

  context "with params" do
    it "adds domain successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/directory/v1/org/#{org_id}/domains") do |env|
        mock_response(body: mock_domain_create, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.domains.add(org_id: org_id, name: domain_name)

      expect(resp).to be_a(Yandex360::Domain)
    end
  end
end