# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#two_fa.status" do
  let(:org_id) { "1130000018743049" }
  let(:user_id) { "1130000061922106" }

  context "with params" do
    it "gets user 2FA status successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/security/v1/org/#{org_id}/users/#{user_id}/2fa/status") do |_env|
        mock_response(body: mock_two_fa_status)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.two_fa.status(org_id: org_id, user_id: user_id)

      expect(resp).to be_a(Yandex360::Object)
    end
  end
end

RSpec.describe "#two_fa.domain_status" do
  let(:org_id) { "1130000018743049" }

  context "with params" do
    it "gets domain 2FA status successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/security/v1/org/#{org_id}/domain_2fa") do |_env|
        mock_response(body: mock_two_fa_domain_status)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.two_fa.domain_status(org_id: org_id)

      expect(resp).to be_a(Yandex360::Object)
    end
  end
end
