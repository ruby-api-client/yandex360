# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::Record do
  # A stand-in for a declared type, so these examples do not depend on the
  # field list of any particular endpoint.
  let(:type) do
    Class.new(described_class) do
      attribute :id
      attribute :change_frequency, from: "changeFrequency"
      attribute :name

      def self.name = "Yandex360::Sample"
    end
  end

  let(:data) do
    {
      "id" => "42",
      "changeFrequency" => 90,
      "name" => {"first" => "Ivan", "last" => "Ivanov"},
      "actions" => [{"action" => "drop"}, {"action" => "forward"}],
      "fieldAddedLater" => "still readable"
    }
  end

  subject(:record) { type.new(data) }

  describe "declared attributes" do
    it "reads a field whose name matches the API" do
      expect(record.id).to eq("42")
    end

    it "reads a renamed field by its Ruby name" do
      expect(record.change_frequency).to eq(90)
    end

    it "returns nil for a declared field the response omits" do
      expect(type.new({}).id).to be_nil
    end
  end

  describe "a misspelled attribute" do
    it "raises rather than returning nil, which is the whole point" do
      expect { record.nam }.to raise_error(NoMethodError)
    end
  end

  describe "the deprecated original spelling" do
    it "still reads the field" do
      expect { expect(record.changeFrequency).to eq(90) }.to output.to_stderr
    end

    it "warns and names the replacement" do
      expect { record.changeFrequency }.to output(/use #change_frequency/).to_stderr
    end

    it "is not defined when the API name already matches" do
      expect(record.method(:id).owner).to eq(type)
    end
  end

  describe "fields the gem does not declare" do
    it "is readable through #[], so a new API field needs no release" do
      expect(record["fieldAddedLater"]).to eq("still readable")
    end

    it "appears in #to_h" do
      expect(record.to_h).to have_key("fieldAddedLater")
    end
  end

  describe "nesting" do
    it "wraps a nested object so its keys read as methods" do
      expect([record.name.first, record.name.last]).to eq(%w[Ivan Ivanov])
    end

    it "wraps each element of an array of objects" do
      expect(record["actions"].map(&:action)).to eq(%w[drop forward])
    end

    it "leaves scalars alone" do
      expect(record.id).to be_a(String)
    end

    it "explains itself when a nested key is absent" do
      expect { record.name.middle }
        .to raise_error(NoMethodError, /readable keys are first, last/)
    end
  end

  describe "value semantics" do
    it "compares by content" do
      expect(record).to eq(type.new(data))
    end

    it "does not compare equal to another type holding the same data" do
      other = Class.new(described_class).new(data)

      expect(record).not_to eq(other)
    end

    it "names its keys when inspected, not their values" do
      expect(record.inspect).to eq("#<Yandex360::Sample id, changeFrequency, name, actions, fieldAddedLater>")
    end
  end
end

RSpec.describe Yandex360::Response do
  subject(:response) { described_class.new({"added" => true, "id" => "7"}) }

  it "reads the keys that arrived, without anything being declared" do
    expect([response.added, response.id]).to eq([true, "7"])
  end

  it "raises for a key that did not arrive" do
    expect { response.removed }.to raise_error(NoMethodError, /not present in this response/)
  end

  it "never shadows a real method, leaving the key to #[]" do
    shadowing = described_class.new({"to_h" => "not the method"})

    expect(shadowing.to_h).to be_a(Hash)
    expect(shadowing["to_h"]).to eq("not the method")
  end

  it "tolerates a body that is not a hash at all" do
    expect(described_class.new("").to_h).to eq({})
  end
end
