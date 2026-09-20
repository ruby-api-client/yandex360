# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "pagination" do
  let(:org_id) { 1_130_000_018_743_049 }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  # Three pages of one user each, so page boundaries are unambiguous.
  def paged_users_stubs
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get("/directory/v1/org/#{org_id}/users") do |env|
      page = env.params["page"].to_i
      mock_response(body: {
                      "users" => [{"id" => "user-#{page}", "nickname" => "user#{page}"}],
                      "page" => page,
                      "pages" => 3,
                      "perPage" => 1,
                      "total" => 3
                    })
    end
    stubs
  end

  describe "metadata" do
    it "exposes page, pages, per_page and total" do
      collection = client_for(paged_users_stubs).users.list(org_id: org_id, per_page: 1)

      expect([collection.page, collection.pages, collection.per_page, collection.total])
        .to eq([1, 3, 1, 3])
    end

    it "derives pages from total and per_page when the endpoint omits it" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/admin/v1/org/#{org_id}/mailboxes/shared") do
        # This endpoint reports total and perPage but no pages.
        mock_response(body: {
                        "resources" => [{"resourceId" => "1", "count" => 1}],
                        "page" => 1, "perPage" => 10, "total" => 25
                      })
      end

      expect(client_for(stubs).mailboxes.shared_list(org_id: org_id).pages).to eq(3)
    end

    it "falls back to the page size for items, which the API never returns" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users") do
        mock_response(body: {"users" => [{"id" => "1"}, {"id" => "2"}], "page" => 1, "pages" => 1})
      end

      expect(client_for(stubs).users.list(org_id: org_id).items).to eq(2)
    end
  end

  describe "#last_page?" do
    it "is false on an early page" do
      expect(client_for(paged_users_stubs).users.list(org_id: org_id, per_page: 1)).not_to be_last_page
    end

    it "is true on the final page" do
      collection = client_for(paged_users_stubs).users.list(org_id: org_id, page: 3, per_page: 1)

      expect(collection).to be_last_page
    end

    it "is true when the endpoint reports no pagination at all" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users") { mock_response(body: {"users" => []}) }

      expect(client_for(stubs).users.list(org_id: org_id)).to be_last_page
    end
  end

  describe "#next_page" do
    it "fetches the following page" do
      first = client_for(paged_users_stubs).users.list(org_id: org_id, per_page: 1)
      second = first.next_page

      expect([second.page, second.first.id]).to eq([2, "user-2"])
    end

    it "returns nil past the end" do
      collection = client_for(paged_users_stubs).users.list(org_id: org_id, page: 3, per_page: 1)

      expect(collection.next_page).to be_nil
    end

    it "carries the original per_page into the request" do
      stubs = Faraday::Adapter::Test::Stubs.new
      seen = []
      stubs.get("/directory/v1/org/#{org_id}/users") do |env|
        seen << env.params["perPage"]
        mock_response(body: {"users" => [], "page" => env.params["page"].to_i, "pages" => 2, "perPage" => 50})
      end

      client_for(stubs).users.list(org_id: org_id, per_page: 50).next_page

      expect(seen).to eq(%w[50 50])
    end
  end

  describe "#each_page" do
    it "walks every page exactly once" do
      collection = client_for(paged_users_stubs).users.list(org_id: org_id, per_page: 1)

      expect(collection.each_page.map(&:page)).to eq([1, 2, 3])
    end

    it "yields a single page when there is no pager" do
      collection = described_class_free_collection

      expect(collection.each_page.to_a.size).to eq(1)
    end
  end

  describe "#auto_paginate" do
    it "yields every record across every page" do
      collection = client_for(paged_users_stubs).users.list(org_id: org_id, per_page: 1)

      expect(collection.auto_paginate.map(&:id)).to eq(%w[user-1 user-2 user-3])
    end

    it "is lazy: nothing beyond the first page is fetched until asked" do
      requested = []
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/users") do |env|
        page = env.params["page"].to_i
        requested << page
        mock_response(body: {
                        "users" => [{"id" => "user-#{page}"}],
                        "page" => page, "pages" => 5, "perPage" => 1, "total" => 5
                      })
      end

      client_for(stubs).users.list(org_id: org_id, per_page: 1).auto_paginate.first(2)

      expect(requested).to eq([1, 2])
    end
  end

  describe "departments" do
    it "keeps parent_id and order_by across pages" do
      seen = []
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/departments") do |env|
        seen << env.params.slice("parentId", "orderBy")
        mock_response(body: {
                        "departments" => [], "page" => env.params["page"].to_i,
                        "pages" => 2, "perPage" => 10, "total" => 20
                      })
      end

      client_for(stubs).departments.list(org_id: org_id, parent_id: 42, order_by: "name").next_page

      expect(seen.uniq).to eq([{"parentId" => "42", "orderBy" => "name"}])
    end
  end

  def described_class_free_collection
    Yandex360::Collection.new(data: [1, 2], items: 2, total: 2)
  end
end
