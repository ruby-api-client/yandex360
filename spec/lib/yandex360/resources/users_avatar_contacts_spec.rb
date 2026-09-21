# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "users avatar, contacts and 2FA phone" do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:user_id) { "1130000061922106" }
  let(:base) { "/directory/v1/org/#{org_id}/users/#{user_id}" }
  let(:png) { "\x89PNG\r\n\x1a\n binary".b }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  def mock_user_with_contacts
    {
      "id" => "1130000061922106",
      "nickname" => "ivan.ivanov",
      "contacts" => [
        {"type" => "phone", "value" => "+70000000000", "main" => true, "synthetic" => false},
        {"type" => "email", "value" => "ivan@example.com", "main" => false, "synthetic" => true}
      ]
    }
  end

  describe "#delete_2fa_phone" do
    it "removes the phone configured for two-factor authentication" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("#{base}/2fa") { mock_response(body: {}) }

      expect(client_for(stubs).users.delete_2fa_phone(org_id: org_id, user_id: user_id))
        .to be_a(Yandex360::Response)
    end

    it "surfaces the 400 the API returns when no phone is set" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("#{base}/2fa") { mock_error_response(status: 400, message: "no phone") }

      client = client_for(stubs)

      expect { client.users.delete_2fa_phone(org_id: org_id, user_id: user_id) }
        .to raise_error(Yandex360::ValidationError)
    end

    it "requires user_id" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.users.delete_2fa_phone(org_id: org_id, user_id: nil) }
        .to raise_error(ArgumentError, /user_id/)
    end
  end

  describe "#update_avatar" do
    it "sends the image as raw bytes, untouched by the JSON middleware" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put("#{base}/avatar") do |env|
        expect(env.body).to eq(png)
        expect(env.request_headers["Content-Type"]).to eq("image/png")
        mock_response(body: {})
      end

      client_for(stubs).users.update_avatar(org_id: org_id, user_id: user_id, image: png)
    end

    it "accepts another content type" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put("#{base}/avatar") do |env|
        expect(env.request_headers["Content-Type"]).to eq("image/jpeg")
        mock_response(body: {})
      end

      client_for(stubs).users.update_avatar(
        org_id: org_id, user_id: user_id, image: png, content_type: "image/jpeg"
      )
    end

    it "requires an image" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.users.update_avatar(org_id: org_id, user_id: user_id, image: nil) }
        .to raise_error(ArgumentError, /image/)
    end
  end

  describe "#update_contacts" do
    it "replaces the contact list and returns the whole user" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put("#{base}/contacts") do |env|
        expect(JSON.parse(env.body)["contacts"].first)
          .to include("type" => "phone", "value" => "+70000000000")
        mock_response(body: mock_user_with_contacts)
      end

      resp = client_for(stubs).users.update_contacts(
        org_id: org_id, user_id: user_id,
        contacts: [{type: "phone", value: "+70000000000", label: "Work"}]
      )

      expect(resp).to be_a(Yandex360::User)
      expect(resp.contacts.first.value).to eq("+70000000000")
    end

    it "requires contacts" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.users.update_contacts(org_id: org_id, user_id: user_id, contacts: []) }
        .to raise_error(ArgumentError, /contacts/)
    end
  end

  describe "#delete_contacts" do
    it "clears the editable contacts and returns the user" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("#{base}/contacts") { mock_response(body: mock_user_with_contacts) }

      resp = client_for(stubs).users.delete_contacts(org_id: org_id, user_id: user_id)

      expect(resp).to be_a(Yandex360::User)
      # Synthetic entries survive: the API generates them and refuses to drop them.
      expect(resp.contacts.map(&:synthetic)).to include(true)
    end
  end
end
