# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#groups.create" do
  let(:org_id) { "1234567" }
  let(:name) { "Hotline" }

  context "with params" do
    it "creates group successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/directory/v1/org/#{org_id}/groups") do |env|
        mock_response(body: mock_group_create, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.groups.create(org_id: org_id, name: name)

      expect(resp).to be_an Yandex360::Group
    end
  end
end

RSpec.describe "#groups.update" do
  let(:name) { "Hotline 247" }
  let(:org_id) { "1234567" }
  let(:group_id) { "19" }

  context "with params" do
    it "updates group successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.patch("/directory/v1/org/#{org_id}/groups/#{group_id}") do |env|
        mock_response(body: mock_group_info)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.groups.update(org_id: org_id, group_id: group_id, name: name)

      expect(resp).to be_an Yandex360::Group
    end
  end
end

RSpec.describe "#groups.params" do
  let(:org_id) { "1234567" }
  let(:group_id) { "19" }

  context "with params" do
    it "gets group params successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/groups/#{group_id}") do |env|
        mock_response(body: mock_group_info)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.groups.params(org_id: org_id, group_id: group_id)

      expect(resp).to be_an Yandex360::Group
    end
  end
end

RSpec.describe "#groups.list" do
  let(:org_id) { "1234567" }

  context "with params" do
    it "returns collection of groups" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/groups") do |env|
        mock_response(body: mock_groups_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.groups.list(org_id: org_id)

      expect(resp).to be_an Yandex360::Collection
      expect(resp.data.first).to be_an Yandex360::Group
    end
  end
end

RSpec.describe "#groups.add_user" do
  let(:org_id) { "1234567" }
  let(:user_id) { "987654321" }

  context "with params" do
    it "adds user to group successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/directory/v1/org/#{org_id}/groups/19/members") do |env|
        mock_response(body: mock_group_add_user, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.groups.add_user(org_id: org_id, group_id: "19", user_id: user_id, type: "user")

      expect(resp).to be_an Yandex360::Group
      expect(resp.added).to be true
      expect(resp.id).to eq user_id
      expect(resp.type).to eq "user"
    end
  end
end

RSpec.describe "#groups.users" do
  let(:org_id) { "1234567" }
  let(:group_id) { "19" }

  context "with params" do
    it "returns group users successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/groups/#{group_id}/members") do |env|
        mock_response(body: mock_group_users)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.groups.users(org_id: org_id, group_id: group_id)

      expect(resp).to be_an Yandex360::Collection
      expect(resp.data.first).to be_an Yandex360::User
    end
  end
end

RSpec.describe "#groups.delete_user" do
  let(:org_id) { "1234567" }
  let(:user_id) { "987654321" }

  context "with params" do
    it "deletes user from group successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("/directory/v1/org/#{org_id}/groups/19/members/user/#{user_id}") do |env|
        mock_response(body: mock_group_delete_user)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.groups.delete_user(org_id: org_id, group_id: "19", type: "user", user_id: user_id)

      expect(resp.removed).to be true
      expect(resp.type).to eq "user"
      expect(resp.id).to eq user_id
    end
  end
end

RSpec.describe "#groups.delete" do
  let(:org_id) { "1234567" }
  let(:group_id) { 19 }

  context "with params" do
    it "deletes group successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("/directory/v1/org/#{org_id}/groups/#{group_id}") do |env|
        mock_response(body: mock_group_delete)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.groups.delete(org_id: org_id, group_id: group_id)

      expect(resp).to be_an Yandex360::Group
      expect(resp.removed).to eq true
      expect(resp.id).to eq group_id
    end
  end
end