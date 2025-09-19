# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#audit.list" do
  let(:org_id) { "1130000018743049" }

  context "with params" do
    it "returns collection of audit events" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/audit/v1/org/#{org_id}/events") do |env|
        mock_response(body: mock_audit_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.audit.list(org_id: org_id, page: 1, per_page: 10)

      expect(resp).to be_a(Yandex360::Collection)
      expect(resp.data.first).to be_a(Yandex360::AuditEvent)
    end
  end
end