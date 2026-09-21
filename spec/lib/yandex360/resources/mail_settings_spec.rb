# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::MailSettingsResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:user_id) { "1130000061922106" }
  let(:base) { "/admin/v1/org/#{org_id}/mail/users/#{user_id}/settings" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "the address book" do
    it "reads whether contacts are collected automatically" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/address_book") { mock_response(body: mock_mail_address_book) }

      resp = client_for(stubs).mail_settings.address_book(org_id: org_id, user_id: user_id)

      expect(resp).to be_a(Yandex360::MailAddressBook)
      expect(resp.collect_addresses).to be(true)
    end

    it "changes it" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("#{base}/address_book") do |env|
        expect(JSON.parse(env.body)).to eq("collectAddresses" => false)
        mock_response(body: {"collectAddresses" => false})
      end

      resp = client_for(stubs).mail_settings.update_address_book(
        org_id: org_id, user_id: user_id, collect_addresses: false
      )

      expect(resp.collect_addresses).to be(false)
    end
  end

  describe "sender info" do
    it "reads the name, address and signatures" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/sender_info") { mock_response(body: mock_mail_sender_info) }

      resp = client_for(stubs).mail_settings.sender_info(org_id: org_id, user_id: user_id)

      expect(resp).to be_a(Yandex360::MailSenderInfo)
      expect([resp.from_name, resp.default_from, resp.sign_position])
        .to eq(["Ivan Ivanov", "ivan@example.com", "bottom"])
      expect(resp.signs.first.text).to eq("Best regards")
    end

    it "converts snake_case arguments to the camelCase the API documents" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("#{base}/sender_info") do |env|
        expect(JSON.parse(env.body))
          .to include("fromName" => "Ivan", "signPosition" => "under")
        mock_response(body: mock_mail_sender_info)
      end

      client_for(stubs).mail_settings.update_sender_info(
        org_id: org_id, user_id: user_id, from_name: "Ivan", sign_position: "under"
      )
    end
  end

  describe "rules" do
    it "returns auto-replies and forwards together, as the endpoint does" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/user_rules") { mock_response(body: mock_mail_user_rules) }

      resp = client_for(stubs).mail_settings.rules(org_id: org_id, user_id: user_id)

      expect(resp).to be_a(Yandex360::MailUserRules)
      expect(resp.autoreplies.first.ruleName).to eq("On holiday")
      expect(resp.forwards.first.address).to eq("archive@example.com")
    end

    it "creates a forward and answers with its id" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("#{base}/user_rules") do |env|
        expect(JSON.parse(env.body))
          .to eq("ruleName" => "To archive", "address" => "archive@example.com",
                 "withStore" => true)
        mock_response(body: mock_mail_rule_created)
      end

      resp = client_for(stubs).mail_settings.create_rule(
        org_id: org_id, user_id: user_id,
        rule_name: "To archive", address: "archive@example.com", with_store: true
      )

      expect(resp).to be_a(Yandex360::MailRule)
      expect(resp.rule_id).to eq(3)
    end

    it "creates an auto-reply through the same endpoint" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("#{base}/user_rules") do |env|
        expect(JSON.parse(env.body)).to eq("ruleName" => "On holiday", "text" => "Back Monday")
        mock_response(body: mock_mail_rule_created)
      end

      client_for(stubs).mail_settings.create_rule(
        org_id: org_id, user_id: user_id, rule_name: "On holiday", text: "Back Monday"
      )
    end

    it "refuses an empty rule rather than posting nothing" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.mail_settings.create_rule(org_id: org_id, user_id: user_id) }
        .to raise_error(ArgumentError, /rule attributes/)
    end

    it "deletes one by id" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("#{base}/user_rules/3") { mock_response(body: {}) }

      expect(client_for(stubs).mail_settings.delete_rule(org_id: org_id, user_id: user_id, rule_id: 3))
        .to be_a(Yandex360::Response)
    end
  end

  describe "validation" do
    it "requires user_id" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.mail_settings.address_book(org_id: org_id, user_id: nil) }
        .to raise_error(ArgumentError, /user_id/)
    end
  end

  describe "the deprecated accessor" do
    it "still reaches the resource and says what to use" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      resource = nil
      expect { resource = client.post_settings }.to output(/use client\.mail_settings/).to_stderr
      expect(resource).to be_a(described_class)
    end
  end
end
