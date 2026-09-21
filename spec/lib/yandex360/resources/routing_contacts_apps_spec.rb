# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::RoutingResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:path) { "/admin/v1/org/#{org_id}/mail/routing/rules" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  it "reads the rule list" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get(path) { mock_response(body: mock_routing_rules) }

    resp = client_for(stubs).routing.list(org_id: org_id)

    expect(resp).to be_a(Yandex360::RoutingRules)
    expect(resp.rules.first.terminal).to be(true)
    expect(resp.rules.first.actions.first.action).to eq("drop")
    expect(resp.rules.first.scope.direction).to eq("inbound")
  end

  it "replaces the rule set" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.put(path) do |env|
      expect(JSON.parse(env.body)["rules"].first).to include("terminal" => true)
      mock_response(body: {})
    end

    expect(client_for(stubs).routing.set(org_id: org_id, rules: mock_routing_rules["rules"]))
      .to be_a(Yandex360::Response)
  end

  it "requires rules" do
    expect { client_for(Faraday::Adapter::Test::Stubs.new).routing.set(org_id: org_id, rules: []) }
      .to raise_error(ArgumentError, /rules/)
  end
end

RSpec.describe Yandex360::ServiceApplicationsResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:path) { "/security/v1/org/#{org_id}/service_applications" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  it "lists applications with their scopes" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get(path) { mock_response(body: mock_service_applications) }

    resp = client_for(stubs).service_applications.list(org_id: org_id)

    expect(resp).to be_a(Yandex360::Collection)
    expect(resp.first).to be_a(Yandex360::ServiceApplication)
    expect(resp.first.id).to eq("app-1")
  end

  it "replaces the stored list" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(path) do |env|
      expect(JSON.parse(env.body)["applications"].first).to include("id" => "app-1")
      mock_response(body: mock_service_applications)
    end

    expect(client_for(stubs).service_applications.create(
             org_id: org_id, applications: mock_service_applications["applications"]
           )).to be_a(Yandex360::Collection)
  end

  it "clears the whole list" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.delete(path) { mock_response(body: {"applications" => []}) }

    expect(client_for(stubs).service_applications.delete(org_id: org_id)).to be_empty
  end

  it "activates the feature" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post("#{path}/activate") { mock_response(body: {}) }

    expect(client_for(stubs).service_applications.activate(org_id: org_id)).to be_a(Yandex360::Response)
  end

  it "deactivates the feature" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post("#{path}/deactivate") { mock_response(body: {}) }

    expect(client_for(stubs).service_applications.deactivate(org_id: org_id)).to be_a(Yandex360::Response)
  end
end

RSpec.describe Yandex360::ExternalContactsResource do
  let(:org_id) { 1_130_000_018_743_049 }
  let(:contact_id) { "contact-1" }
  let(:base) { "/directory/v1/org/#{org_id}/external_contacts" }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  it "lists contacts with pagination defaults" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get(base) do |env|
      expect(env.params).to include("page" => "1", "perPage" => "10")
      mock_response(body: mock_external_contacts_list)
    end

    resp = client_for(stubs).external_contacts.list(org_id: org_id)

    expect(resp.first).to be_a(Yandex360::ExternalContact)
    expect(resp.first.emails.first.email).to eq("ivan@partner.example")
  end

  it "creates a contact, camel casing the name fields" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(base) do |env|
      body = JSON.parse(env.body)
      expect(body).to include("firstName" => "Ivan", "lastName" => "Petrov")
      expect(body["emails"].first).to include("email" => "ivan@partner.example")
      mock_response(body: {"id" => contact_id})
    end

    resp = client_for(stubs).external_contacts.create(
      org_id: org_id, first_name: "Ivan", last_name: "Petrov",
      emails: [{email: "ivan@partner.example", main: true}]
    )

    expect(resp.id).to eq(contact_id)
  end

  it "rejects a contact without an email, which the API requires" do
    client = client_for(Faraday::Adapter::Test::Stubs.new)

    creating = lambda do
      client.external_contacts.create(org_id: org_id, first_name: "Ivan", last_name: "Petrov", emails: [])
    end

    expect(&creating).to raise_error(ArgumentError, /emails/)
  end

  it "reads one contact" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get("#{base}/#{contact_id}") { mock_response(body: mock_external_contact) }

    expect(client_for(stubs).external_contacts.info(org_id: org_id, contact_id: contact_id).lastName)
      .to eq("Petrov")
  end

  it "patches only the fields given" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.patch("#{base}/#{contact_id}") do |env|
      expect(JSON.parse(env.body)).to eq("company" => "Partner Ltd")
      mock_response(body: mock_external_contact)
    end

    client_for(stubs).external_contacts.update(org_id: org_id, contact_id: contact_id, company: "Partner Ltd")
  end

  it "deletes a contact" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.delete("#{base}/#{contact_id}") { mock_response(body: {}) }

    expect(client_for(stubs).external_contacts.delete(org_id: org_id, contact_id: contact_id))
      .to be_a(Yandex360::Response)
  end

  it "replaces the email list through its own endpoint" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.put("#{base}/#{contact_id}/emails") do |env|
      expect(JSON.parse(env.body)["emails"].first).to include("main" => true)
      mock_response(body: mock_external_contact)
    end

    client_for(stubs).external_contacts.update_emails(
      org_id: org_id, contact_id: contact_id,
      emails: [{email: "ivan@partner.example", main: true}]
    )
  end

  it "replaces the phone list through its own endpoint" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.put("#{base}/#{contact_id}/phones") do |env|
      expect(JSON.parse(env.body)["phones"].first).to include("phone" => "+70000000000")
      mock_response(body: mock_external_contact)
    end

    client_for(stubs).external_contacts.update_phones(
      org_id: org_id, contact_id: contact_id,
      phones: [{phone: "+70000000000", main: true}]
    )
  end
end
