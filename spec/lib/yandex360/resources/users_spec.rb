# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#users.list" do
  let(:org_id) { "1234567" }

  context "with params" do
    it "returns collection of users" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users") do |_|
        mock_response(body: mock_users_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.list(org_id: org_id)

      expect(resp).to be_an(Yandex360::Collection)
      expect(resp.data.first).to be_an(Yandex360::User)
    end
  end

  context "with error" do
    let(:org_id) { "3287461283" }

    it "raises authorization error" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users") do |_|
        mock_error_response(status: 403, message: "You are not allowed to perform that action")
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      expect { client.users.list(org_id: org_id) }.to raise_error(Yandex360::AuthorizationError, /not allowed/)
    end
  end
end

RSpec.describe "#users.add" do
  let(:org_id) { "1234567" }

  context "with params" do
    it "creates user successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/directory/v1/org/#{org_id}/users") do |_|
        mock_response(body: mock_user_create, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.add(
        org_id: org_id,
        dep_id: 1,
        about: "Yandex360",
        name: {
          first: "Ivan",
          last: "Ivanov",
          middle: "Ruby"
        },
        nickname: "yandex360",
        password: "W!846f456678"
      )

      expect(resp).to be_an(Yandex360::User)
      expect(resp.name.first).to eq "Ivan"
      expect(resp.name.last).to eq "Yandex360"
    end
  end
end

RSpec.describe "#users.update" do
  let(:user_id) { "1130000061922106" }
  let(:org_id) { "1234567" }

  context "with params" do
    it "updates user successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.patch("/directory/v1/org/#{org_id}/users/#{user_id}") do |_|
        mock_response(body: mock_user_update)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.update(
        org_id: org_id,
        user_id: user_id,
        about: "Yandex360 - Ruby API gem",
        name: {
          first: "Ruby",
          last: "gem",
          middle: "API"
        },
        nickname: "yandex360-ruby-api-client",
        password: "passswrrdwithstrrngscrrty"
      )

      expect(resp).to be_an(Yandex360::User)
      expect(resp.id).to eq user_id
      expect(resp.name.first).to eq "Ruby"
      expect(resp.name.last).to eq "Yandex360 - Ruby API gem"
    end
  end
end

RSpec.describe "#users.add_alias" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }
  let(:user_alias) { "ruby_gem_api" }

  context "with params" do
    it "adds alias successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/directory/v1/org/#{org_id}/users/#{user_id}/aliases") do |_|
        mock_response(body: mock_user_alias, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.add_alias(org_id: org_id, user_id: user_id, user_alias: user_alias)

      expect(resp).to be_an(Yandex360::User)
      expect(resp.alias).to eq user_alias
    end
  end
end

RSpec.describe "#users.delete_alias" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }
  let(:user_alias) { "ruby_gem_api" }

  context "with params" do
    it "deletes alias successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("/directory/v1/org/#{org_id}/users/#{user_id}/aliases/#{user_alias}") do |_|
        mock_response(body: mock_user_alias_delete)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.delete_alias(org_id: org_id, user_id: user_id, user_alias: user_alias)

      expect(resp).to be_an(Yandex360::Alias)
      expect(resp.alias).to eq user_alias
      expect(resp.removed).to be(true)
    end
  end
end

RSpec.describe "#users.get2FA" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }

  context "with params" do
    it "gets 2FA info successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users/#{user_id}/2fa") do |_|
        mock_response(body: mock_user_2fa)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.get2FA(org_id: org_id, user_id: user_id)

      expect(resp).to be_an(Yandex360::Object)
      expect(resp.id).to eq("1130000018743049")
      expect(resp.has2fa).to be(true).or be(false)
    end
  end

  context "with error" do
    it "raises authorization error" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/123/users/123/2fa") do |_|
        mock_error_response(status: 403, message: "You are not allowed to perform that action")
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      expect { client.users.get2FA(org_id: 123, user_id: 123) }
        .to raise_error(Yandex360::AuthorizationError, /not allowed/)
    end
  end
end

RSpec.describe "#users.has2FA?" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }

  context "with params" do
    it "returns 2FA status" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users/#{user_id}/2fa") do |_|
        mock_response(body: mock_user_2fa)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.has2FA?(org_id: org_id, user_id: user_id)

      expect(resp).to be(true).or be(false)
    end
  end
end

RSpec.describe "#users.info" do
  let(:org_id) { "1234567" }
  let(:user_id) { "987654321" }

  context "with params" do
    it "gets user info successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users/#{user_id}") do |_|
        mock_response(body: mock_user_info)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.info(org_id: org_id, user_id: user_id)

      expect(resp).to be_an(Yandex360::User)
      expect(resp.name).to be_an(OpenStruct)
      expect(resp.contacts).to be_an(Array)
    end
  end

  context "without params" do
    it "raises argument error" do
      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: nil)
      expect { client.users.info }.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe "#users.delete" do
  let(:org_id) { "12345678" }
  let(:user_id) { "12345678" }

  context "with params" do
    it "deletes user successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("/directory/v1/org/#{org_id}/users/#{user_id}") do |_|
        mock_response(body: mock_user_info)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.users.delete(org_id: org_id, user_id: user_id)

      expect(resp).to be_an Yandex360::User
    end
  end

  context "without params" do
    it "raises argument error" do
      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: nil)
      expect { client.users.delete }.to raise_error(ArgumentError)
    end
  end
end
