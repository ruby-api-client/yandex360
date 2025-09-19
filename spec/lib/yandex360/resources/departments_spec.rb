# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#departments.list" do
  let(:org_id) { "1234567" }

  context "with params" do
    it "returns collection of departments" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/departments") do |_env|
        mock_response(body: mock_departments_list)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.departments.list(org_id: org_id)

      expect(resp).to be_a Yandex360::Collection
      expect(resp.data.first).to be_an Yandex360::Department
    end
  end
end

RSpec.describe "#departments.create" do
  let(:org_id) { "1234567" }

  context "with params" do
    it "creates department successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/directory/v1/org/#{org_id}/departments") do |_env|
        mock_response(body: mock_department_create, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.departments.create(org_id: org_id, name: "Support", parent_id: 1)

      expect(resp).to be_an Yandex360::Department
    end
  end
end

RSpec.describe "#departments.update" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }
  let(:parent_id) { "1" }

  context "with params" do
    it "updates department successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.patch("/directory/v1/org/#{org_id}/departments/#{dep_id}") do |_env|
        mock_response(body: mock_department_info)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.departments.update(
        org_id: org_id,
        dep_id: dep_id,
        parent_id: parent_id,
        description: "Yandex360",
        name: "Support Team",
        label: "support-team"
      )

      expect(resp).to be_an Yandex360::Department
    end
  end
end

RSpec.describe "#departments.info" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }

  context "with params" do
    it "gets department info successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("/directory/v1/org/#{org_id}/departments/#{dep_id}") do |_env|
        mock_response(body: mock_department_info)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.departments.info(dep_id: dep_id, org_id: org_id)

      expect(resp).to be_an(Yandex360::Department)
    end
  end
end

RSpec.describe "#departments.add_alias" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }
  let(:name) { "support-team" }

  context "with params" do
    it "adds alias successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("/directory/v1/org/#{org_id}/departments/#{dep_id}/aliases") do |_env|
        mock_response(body: mock_department_alias, status: 201)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.departments.add_alias(org_id: org_id, dep_id: dep_id, name: name)

      expect(resp).to be_an Yandex360::DepartmentAlias
      expect(resp.alias).to eq name
    end
  end
end

RSpec.describe "#departments.delete_alias" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }
  let(:name) { "support-team" }

  context "with params" do
    it "deletes alias successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("/directory/v1/org/#{org_id}/departments/#{dep_id}/aliases/#{name}") do |_env|
        mock_response(body: mock_department_alias_delete)
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.departments.delete_alias(org_id: org_id, dep_id: dep_id, name: name)

      expect(resp).to be_an Yandex360::Object
      expect(resp.removed).to be true
      expect(resp.alias).to eq name
    end
  end
end

RSpec.describe "#departments.delete" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }

  context "with params" do
    it "deletes department successfully" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("/directory/v1/org/#{org_id}/departments/#{dep_id}") do |_env|
        mock_response(body: {"removed" => true, "id" => dep_id})
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      resp = client.departments.delete(org_id: org_id, dep_id: dep_id)

      expect(resp).to be_an(Yandex360::Object)
    end
  end

  context "with error" do
    it "raises not found error" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("/directory/v1/org/#{org_id}/departments/#{dep_id}") do |_env|
        mock_error_response(status: 404, message: "No results were found for your request")
      end

      client = Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
      expect {
        client.departments.delete(org_id: org_id, dep_id: dep_id)
      }.to raise_error(Yandex360::NotFoundError, /No results/)
    end
  end
end
