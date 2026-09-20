# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::ParamBuilder do
  let(:org_id) { 1_130_000_018_743_049 }

  def client_for(stubs)
    Yandex360::Client.new(token: "test_token", adapter: :test, stubs: stubs)
  end

  it "refuses a keyword that collides with a field the method fills in" do
    client = client_for(Faraday::Adapter::Test::Stubs.new)

    # lastName is what the method derives from last_name, so passing both means
    # one of the two would be dropped. It used to be the declared one.
    creating = lambda do
      client.external_contacts.create(
        org_id: org_id, first_name: "Ivan", last_name: "Petrov",
        emails: [{email: "ivan@partner.example", main: true}],
        lastName: nil
      )
    end

    expect(&creating).to raise_error(ArgumentError, /Duplicate parameters: lastName/)
  end

  it "still accepts extra keywords that do not collide" do
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post("/directory/v1/org/#{org_id}/external_contacts") do |env|
      expect(JSON.parse(env.body)).to include("lastName" => "Petrov", "company" => "Partner Ltd")
      mock_response(body: {"id" => "contact-1"})
    end

    client_for(stubs).external_contacts.create(
      org_id: org_id, first_name: "Ivan", last_name: "Petrov",
      emails: [{email: "ivan@partner.example", main: true}],
      company: "Partner Ltd"
    )
  end

  it "guards the other resources that build params the same way" do
    client = client_for(Faraday::Adapter::Test::Stubs.new)

    # users.add fills in departmentId from dep_id.
    adding = lambda do
      client.users.add(org_id: org_id, dep_id: 1, nickname: "ivan", departmentId: 2)
    end

    expect(&adding).to raise_error(ArgumentError, /Duplicate parameters: departmentId/)
  end
end
