# frozen_string_literal: true

require "spec_helper"
require "yandex360"

# Which lists paginate, and how, was taken from the reference one endpoint at a
# time. Three do, and not all in the same way; the rest answer everything at
# once and are left alone rather than given arguments the API ignores.
RSpec.describe "pagination across the lists that have it" do
  let(:org_id) { 1_130_000_018_743_049 }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "domains" do
    it "sends page and perPage, capped at 10 by the API" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/domains") do |env|
        expect(env.params).to include("page" => "1", "perPage" => "10")
        mock_response(body: {"domains" => [{"name" => "example.com"}],
                             "page" => 1, "pages" => 2, "perPage" => 10, "total" => 11})
      end

      collection = client_for(stubs).domains.list(org_id: org_id)

      expect(collection.pages).to eq(2)
      expect(collection).not_to be_last_page
    end

    it "walks to the next page" do
      seen = []
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/domains") do |env|
        page = env.params["page"].to_i
        seen << page
        mock_response(body: {"domains" => [{"name" => "example#{page}.com"}],
                             "page" => page, "pages" => 2, "perPage" => 10, "total" => 11})
      end

      client_for(stubs).domains.list(org_id: org_id).next_page

      expect(seen).to eq([1, 2])
    end
  end

  describe "dns records" do
    it "defaults per_page to the 50 the API uses" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/domains/example.com/dns") do |env|
        expect(env.params).to include("perPage" => "50")
        mock_response(body: {"records" => [{"recordId" => 1, "type" => "A"}],
                             "page" => 1, "pages" => 1, "perPage" => 50, "total" => 1})
      end

      collection = client_for(stubs).dns.list(org_id: org_id, domain: "example.com")

      expect(collection.first.record_id).to eq(1)
      expect(collection).to be_last_page
    end

    it "carries the domain into the following pages" do
      seen = []
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/domains/example.com/dns") do |env|
        seen << env.params["page"]
        mock_response(body: {"records" => [], "page" => env.params["page"].to_i,
                             "pages" => 2, "perPage" => 50, "total" => 60})
      end

      client_for(stubs).dns.list(org_id: org_id, domain: "example.com").next_page

      expect(seen).to eq(%w[1 2])
    end
  end

  describe "organizations" do
    it "pages by token, like the audit log, so there is no page argument" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") do |env|
        expect(env.params).to include("pageSize" => "10")
        expect(env.params).not_to have_key("page")
        mock_response(body: {"organizations" => [{"id" => 1, "name" => "Acme"}],
                             "nextPageToken" => "token-2"})
      end

      collection = client_for(stubs).organizations.list

      expect(collection.next_cursor).to eq("token-2")
      expect(collection).not_to be_last_page
    end

    it "follows the token" do
      tokens = []
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org") do |env|
        token = env.params["pageToken"]
        tokens << token
        body = {"organizations" => [{"id" => 1}]}
        body["nextPageToken"] = "token-2" if token.nil?
        mock_response(body: body)
      end

      client_for(stubs).organizations.list.each_page.to_a

      expect(tokens).to eq([nil, "token-2"])
    end
  end

  describe "the lists that do not paginate" do
    it "leaves group members, mailbox access and service applications alone" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect(client.groups.method(:users).parameters.map(&:last)).to eq(%i[org_id group_id])
      expect(client.mailboxes.method(:actors).parameters.map(&:last)).to eq(%i[org_id resource_id])
      expect(client.service_applications.method(:list).parameters.map(&:last)).to eq([:org_id])
    end
  end
end

RSpec.describe "#groups.members" do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:group_id) { 19 }

  it "answers all three kinds of member, which #users hides two of" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get("/directory/v1/org/#{org_id}/groups/#{group_id}/members") do
      mock_response(body: {
                      "users" => [{"id" => "1", "nickname" => "ivan"}],
                      "groups" => [{"id" => 2, "name" => "Admins"}],
                      "departments" => [{"id" => 3, "name" => "Support"}]
                    })
    end

    client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
    resp = client.groups.members(org_id: org_id, group_id: group_id)

    expect(resp).to be_a(Yandex360::GroupMembers)
    expect(resp.users.first.nickname).to eq("ivan")
    expect(resp.groups.first.name).to eq("Admins")
    expect(resp.departments.first.name).to eq("Support")
  end
end
