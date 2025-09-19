# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#anispam.create" do
  let(:org_id) { "1234567" }

  context "when create" do
    it "creates allowlist successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/admin/v1/org/#{org_id}/mail/antispam/allowlist/ips") do |env|
        expect(env.body).to include("allowList")
        mock_response(body: mock_antispam_create, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.antispam.create(org_id, "127.0.0.1", "172.0.1.10")

      expect(resp).to be_an Yandex360::AllowList
    end
  end
end

RSpec.describe "#anispam.list" do
  let(:org_id) { "1234567" }

  context "when list" do
    it "returns allowlist successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/admin/v1/org/#{org_id}/mail/antispam/allowlist/ips") do |_env|
        mock_response(body: mock_antispam_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.antispam.list(org_id: org_id)

      expect(resp).to be_an Yandex360::AllowList
    end
  end
end

RSpec.describe "#anispam.delete" do
  let(:org_id) { "1234567" }

  context "when delete" do
    it "deletes allowlist successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("/admin/v1/org/#{org_id}/mail/antispam/allowlist/ips") do |_env|
        [200, {"content-type" => "application/json"}, ""]
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.antispam.delete(org_id: org_id)

      expect(resp.status).to eq 200
    end
  end
end
