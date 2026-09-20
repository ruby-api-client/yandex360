# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::AuditResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:mail_path) { "/security/v1/org/#{org_id}/audit_log/mail" }
  let(:disk_path) { "/security/v1/org/#{org_id}/audit_log/disk" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "#mail" do
    it "reads the mail log and defaults pageSize to the documented maximum" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(mail_path) do |env|
        expect(env.params).to include("pageSize" => "100")
        expect(env.params).not_to have_key("pageToken")
        mock_response(body: mock_mail_audit_log)
      end

      resp = client_for(stubs).audit.mail(org_id: org_id)

      expect(resp).to be_a(Yandex360::Collection)
      expect(resp.first).to be_a(Yandex360::AuditEvent)
      expect(resp.first.eventType).to eq("message_receive")
    end

    it "converts snake_case filters to the camelCase the API documents" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(mail_path) do |env|
        expect(env.params).to include(
          "afterDate" => "2026-01-01T00:00:00Z",
          "beforeDate" => "2026-02-01T00:00:00Z"
        )
        mock_response(body: mock_mail_audit_log)
      end

      client_for(stubs).audit.mail(
        org_id: org_id,
        after_date: "2026-01-01T00:00:00Z",
        before_date: "2026-02-01T00:00:00Z"
      )
    end

    it "sends pageToken when one is given" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(mail_path) do |env|
        expect(env.params).to include("pageToken" => "token-2")
        mock_response(body: mock_mail_audit_log)
      end

      client_for(stubs).audit.mail(org_id: org_id, page_token: "token-2")
    end
  end

  describe "#disk" do
    it "reads the disk log, which is a separate endpoint" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(disk_path) { mock_response(body: mock_disk_audit_log) }

      resp = client_for(stubs).audit.disk(org_id: org_id)

      expect(resp.first.eventType).to eq("fs-store")
      expect(resp.first.path).to eq("/disk/report.xlsx")
    end
  end

  describe "token pagination" do
    it "follows nextPageToken rather than a page number" do
      tokens = []
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(mail_path) do |env|
        token = env.params["pageToken"]
        tokens << token
        next_token = token.nil? ? "token-2" : nil
        mock_response(body: mock_mail_audit_log(next_page_token: next_token))
      end

      pages = client_for(stubs).audit.mail(org_id: org_id).each_page.to_a

      expect(pages.size).to eq(2)
      expect(tokens).to eq([nil, "token-2"])
    end

    it "reports the last page when no token comes back" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(mail_path) { mock_response(body: mock_mail_audit_log) }

      collection = client_for(stubs).audit.mail(org_id: org_id)

      expect(collection).to be_last_page
      expect(collection.next_page).to be_nil
    end

    it "exposes the token through next_cursor" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(mail_path) { mock_response(body: mock_mail_audit_log(next_page_token: "token-2")) }

      expect(client_for(stubs).audit.mail(org_id: org_id).next_cursor).to eq("token-2")
    end

    it "carries the filters across pages" do
      seen = []
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(mail_path) do |env|
        seen << env.params["afterDate"]
        next_token = env.params["pageToken"].nil? ? "token-2" : nil
        mock_response(body: mock_mail_audit_log(next_page_token: next_token))
      end

      client_for(stubs).audit.mail(org_id: org_id, after_date: "2026-01-01T00:00:00Z").next_page

      expect(seen).to eq(["2026-01-01T00:00:00Z"] * 2)
    end
  end

  describe "validation" do
    it "requires org_id" do
      expect { client_for(Faraday::Adapter::Test::Stubs.new).audit.mail(org_id: nil) }
        .to raise_error(ArgumentError, /org_id/)
    end
  end
end
