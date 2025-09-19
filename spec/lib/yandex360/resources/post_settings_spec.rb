# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#post_settings.list" do
  let(:org_id) { "1130000018743049" }
  let(:user_id) { "1130000061922106" }

  context "with params" do
    it "gets post settings successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users/#{user_id}/settings/mail") do |_env|
        mock_response(body: mock_post_settings_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.post_settings.list(org_id: org_id, user_id: user_id)

      expect(resp).to be_a(Yandex360::Object)
    end
  end
end

RSpec.describe "#post_settings.forwarding_list" do
  let(:org_id) { "1130000018743049" }
  let(:user_id) { "1130000061922106" }

  context "with params" do
    it "gets forwarding list successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users/#{user_id}/settings/mail/forwarding") do |_env|
        mock_response(body: mock_post_settings_forwarding_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.post_settings.forwarding_list(org_id: org_id, user_id: user_id)

      expect(resp).to be_a(Yandex360::Collection)
    end
  end
end
