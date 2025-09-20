# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#organizations.list" do
  context "when list" do
    it "returns collection of organizations" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") do |_env|
        mock_response(body: mock_organizations_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.organizations.list

      expect(resp).to be_a(Yandex360::Collection)
      expect(resp.data.first).to be_a(Yandex360::Organization)
    end
  end
end

RSpec.describe "#organizations.info" do
  let(:org_id) { "1130000018743049" }

  context "with params" do
    it "gets organization info successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}") do |_env|
        mock_response(body: mock_organization_info)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.organizations.info(org_id: org_id)

      expect(resp).to be_a(Yandex360::Organization)
    end
  end
end
