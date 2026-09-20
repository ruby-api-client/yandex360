# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::MailboxesResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:resource_id) { "1130000000000001" }
  let(:actor_id) { "1130000000000009" }
  let(:base) { "/admin/v1/org/#{org_id}/mailboxes" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  describe "shared mailboxes" do
    it "lists them with pagination defaults" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/shared") do |env|
        expect(env.params).to include("page" => "1", "perPage" => "10")
        mock_response(body: mock_shared_mailboxes_list)
      end

      resp = client_for(stubs).mailboxes.shared_list(org_id: org_id)

      expect(resp).to be_a(Yandex360::Collection)
      expect(resp.first).to be_a(Yandex360::MailboxResource)
      expect(resp.first.resourceId).to eq(resource_id)
      expect(resp.total).to eq(1)
    end

    it "passes explicit pagination through" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/shared") do |env|
        expect(env.params).to include("page" => "3", "perPage" => "50")
        mock_response(body: mock_shared_mailboxes_list)
      end

      client_for(stubs).mailboxes.shared_list(org_id: org_id, page: 3, per_page: 50)
    end

    it "creates one" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put("#{base}/shared") do |env|
        expect(JSON.parse(env.body)).to eq(
          "email" => "support@example.com", "name" => "Support", "description" => "Shared support mailbox"
        )
        mock_response(body: mock_mailbox_resource_id)
      end

      resp = client_for(stubs).mailboxes.create_shared(
        org_id: org_id, email: "support@example.com", name: "Support", description: "Shared support mailbox"
      )

      expect(resp).to be_a(Yandex360::Mailbox)
      expect(resp.resourceId).to eq(resource_id)
    end

    it "reads one" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/shared/#{resource_id}") { mock_response(body: mock_shared_mailbox) }

      resp = client_for(stubs).mailboxes.shared_info(org_id: org_id, resource_id: resource_id)

      expect(resp.email).to eq("support@example.com")
    end

    it "updates one with only the given attributes" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put("#{base}/shared/#{resource_id}") do |env|
        expect(JSON.parse(env.body)).to eq("name" => "Helpdesk")
        mock_response(body: mock_mailbox_resource_id)
      end

      client_for(stubs).mailboxes.update_shared(org_id: org_id, resource_id: resource_id, name: "Helpdesk")
    end

    it "deletes one" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("#{base}/shared/#{resource_id}") { mock_response(body: {}) }

      expect(client_for(stubs).mailboxes.delete_shared(org_id: org_id, resource_id: resource_id))
        .to be_a(Yandex360::Response)
    end
  end

  describe "delegated mailboxes" do
    it "lists them" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/delegated") { mock_response(body: mock_shared_mailboxes_list) }

      expect(client_for(stubs).mailboxes.delegated_list(org_id: org_id)).to be_a(Yandex360::Collection)
    end

    it "enables delegation" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.put("#{base}/delegated") do |env|
        expect(JSON.parse(env.body)).to eq("resourceId" => resource_id)
        mock_response(body: mock_mailbox_resource_id)
      end

      expect(client_for(stubs).mailboxes.create_delegated(org_id: org_id, resource_id: resource_id))
        .to be_a(Yandex360::Mailbox)
    end

    it "disables delegation" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.delete("#{base}/delegated/#{resource_id}") { mock_response(body: {}) }

      expect(client_for(stubs).mailboxes.delete_delegated(org_id: org_id, resource_id: resource_id))
        .to be_a(Yandex360::Response)
    end
  end

  describe "access rights" do
    it "lists the employees who can reach a mailbox" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/actors/#{resource_id}") { mock_response(body: mock_mailbox_actors) }

      resp = client_for(stubs).mailboxes.actors(org_id: org_id, resource_id: resource_id)

      expect(resp.first).to be_a(Yandex360::MailboxActor)
      expect(resp.first.roles).to include("shared_mailbox_reader")
    end

    it "lists the mailboxes an employee can reach" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/resources/#{actor_id}") { mock_response(body: mock_mailbox_resources) }

      resp = client_for(stubs).mailboxes.resources(org_id: org_id, actor_id: actor_id)

      expect(resp.first.type).to eq("shared")
    end

    it "sets roles, sending actor_id as a query parameter and roles as the body" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("#{base}/set/#{resource_id}") do |env|
        expect(env.params).to include("actorId" => actor_id)
        expect(env.params).not_to have_key("notify")
        expect(JSON.parse(env.body)).to eq("roles" => ["shared_mailbox_reader"])
        mock_response(body: mock_mailbox_task)
      end

      resp = client_for(stubs).mailboxes.set_access(
        org_id: org_id, resource_id: resource_id, actor_id: actor_id, roles: ["shared_mailbox_reader"]
      )

      expect(resp).to be_a(Yandex360::MailboxTask)
      expect(resp.taskId).to eq("task-42")
    end

    it "passes notify through when given" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post("#{base}/set/#{resource_id}") do |env|
        expect(env.params).to include("notify" => "none")
        mock_response(body: mock_mailbox_task)
      end

      client_for(stubs).mailboxes.set_access(
        org_id: org_id, resource_id: resource_id, actor_id: actor_id,
        roles: ["shared_mailbox_reader"], notify: "none"
      )
    end

    it "reports task status" do
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get("#{base}/tasks/task-42") { mock_response(body: mock_mailbox_task_status) }

      expect(client_for(stubs).mailboxes.task_status(org_id: org_id, task_id: "task-42").status)
        .to eq("complete")
    end
  end

  describe "validation" do
    it "requires resource_id where the path needs it" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      expect { client.mailboxes.shared_info(org_id: org_id, resource_id: nil) }
        .to raise_error(ArgumentError, /resource_id/)
    end

    it "requires roles when setting access" do
      client = client_for(Faraday::Adapter::Test::Stubs.new)

      setting_empty_roles = lambda do
        client.mailboxes.set_access(org_id: org_id, resource_id: resource_id, actor_id: actor_id, roles: [])
      end

      expect(&setting_empty_roles).to raise_error(ArgumentError, /roles/)
    end
  end
end
